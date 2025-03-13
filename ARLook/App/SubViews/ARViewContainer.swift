//
//  ARViewContainer.swift
//  ARLook
//
//  Created by Narek on 28.02.25.
//

import ARKit
import Combine
import FocusEntity
import RealityKit
import SwiftUI

struct ARViewContainer: UIViewRepresentable {

  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue
  @Binding var fileURL: URL?
  @Binding var focusEntity: FocusEntity?
  @Binding var isLoading: Bool

  let arView: ARView

  init(
    fileURL: Binding<URL?> = .constant(nil),
    focusEntity: Binding<FocusEntity?> = .constant(nil),
    isLoading: Binding<Bool> = .constant(false),
    arView: ARView
  ) {
    self._fileURL = fileURL
    self._focusEntity = focusEntity
    self._isLoading = isLoading
    self.arView = arView
  }

  func makeCoordinator() -> ARViewContainerCoordinator {
    Coordinator(
      self,
      focusEntity: $focusEntity,
      isLoading: $isLoading,
      accentColor: UIColor(accentColorType.color)
    )
  }

  func makeUIView(context: Context) -> ARView {
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = [.horizontal, .vertical]
    arView.session.run(configuration)
    context.coordinator.setupARView(arView, accentColor: UIColor(accentColorType.color))

    return arView
  }

  func updateUIView(_ uiView: ARView, context: Context) {}

}

class ARViewContainerCoordinator: NSObject, ARSessionDelegate {

  @Binding var focusEntity: FocusEntity?
  @Binding var isLoading: Bool

  private var parent: ARViewContainer!
  private let accentColor: UIColor!
  private var cancellables = Set<AnyCancellable>()
  private var arrowEntity: Entity?
  private var selectedEntity: Entity?
  private var isShowArrow: Bool = true
  private var originalScale: SIMD3<Float>?

  private lazy var directionalLight: Entity = {
    let lightEntity = Entity()
    var light = DirectionalLightComponent(color: .white, intensity: 3000)
    /// Adjust brightness
    light.isRealWorldProxy = false
    lightEntity.components.set(light)
    /// Rotate light for better effect
    lightEntity.transform.rotation = simd_quatf(angle: -.pi / 4, axis: [1, 0, 0])
    return lightEntity
  }()

  init(
    _ parent: ARViewContainer,
    focusEntity: Binding<FocusEntity?>,
    isLoading: Binding<Bool>,
    accentColor: UIColor
  ) {
    self.parent = parent
    self.accentColor = accentColor
    self._focusEntity = focusEntity
    self._isLoading = isLoading
    super.init()
  }

  deinit {
    NotificationCenter.default.removeObserver(self, name: .placeModel, object: nil)
    NotificationCenter.default.removeObserver(self, name: .reset, object: nil)
    NotificationCenter.default.removeObserver(self, name: .snapshot, object: nil)
    NotificationCenter.default.removeObserver(self, name: .toggleArrowVisibility, object: nil)
    NotificationCenter.default.removeObserver(self, name: .deleteSelectedEntity, object: nil)
    parent.arView.session.pause()
  }

  func setupARView(_ arView: ARView, accentColor: UIColor) {
    arView.session.delegate = self

    setupSubviews(arView)
    loadArrowEntity()

    NotificationCenter.default.addObserver(self, selector: #selector(placeModel), name: .placeModel, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(resetScene), name: .reset, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(snapshotAction), name: .snapshot, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(toggleModelSelection), name: .toggleArrowVisibility, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(deleteSelectedEntity), name: .deleteSelectedEntity, object: nil)
  }

  private func setupSubviews(_ arView: ARView) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      focusEntity = FocusEntity(on: arView, style: .classic(color: accentColor))
    }
  }

  private func hideShowArrow() {
    for anchor in parent.arView.scene.anchors {
      if let modelEntity = anchor.findEntity(named: "Arrow") {
        modelEntity.isEnabled = isShowArrow
        NotificationCenter.default.post(name: .showSelected, object: isShowArrow)
      }
    }
  }

  @objc private func toggleModelSelection() {
    isShowArrow.toggle()
    hideShowArrow()
  }

  @objc private func placeModel() {
    guard let focusEntity = focusEntity, let fileURL = parent.fileURL else { return }
    let focusTransform = focusEntity.transformMatrix(relativeTo: nil)
    let finalTransform = getEntityTransform(for: focusTransform)
    isLoading = true
    if let modelEntity = getExistingModelEntityClone() {
      addExistingEntity(modelEntity, transform: finalTransform)
    } else {
      loadPlacedEntity(fileURL: fileURL, transform: finalTransform)
    }
  }
  
  private func loadPlacedEntity(fileURL: URL, transform: float4x4) {
    let modelEntityRequest = Entity.loadAsync(contentsOf: fileURL)
    if arrowEntity.isNil {
      loadArrowEntity()
    }
    modelEntityRequest
      .receive(on: DispatchQueue.main)
      .sink { result in
        switch result {
        case .failure(let error): print("Failed with error: \(error.localizedDescription)")
        case .finished: print("Successfully loaded model")
        }
      } receiveValue: { [weak self] modelEntity in
        guard let self else { return }
        modelEntity.addChild(directionalLight)
        modelEntity.name = fileURL.absoluteString
        let anchorEntity = AnchorEntity(world: transform)
        anchorEntity.addChild(modelEntity)
        parent.arView.scene.addAnchor(anchorEntity)
        isLoading = false
        modelEntity.generateCollisionShapes(recursive: true)
        modelEntity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
          mode: .kinematic
        )
        enableGestures(arView: parent.arView, for: modelEntity)
        if let selectedEntity {
          addHighlightForEntity(for: selectedEntity)
        } else {
          addHighlightForEntity(for: modelEntity)
        }
      }
      .store(in: &cancellables)
  }
  
  private func addExistingEntity(_ modelEntity: Entity, transform: float4x4) {
    modelEntity.scale = .init(x: 1, y: 1, z: 1)
    modelEntity.transform.rotation = .init(angle: 0, axis: [0, 0, 0])
    let anchorEntity = AnchorEntity(world: transform)
    anchorEntity.addChild(modelEntity)
    parent.arView.scene.addAnchor(anchorEntity)
    deleteHighlightedForEntity()
    isLoading = false
    if let selectedEntity {
      addHighlightForEntity(for: selectedEntity)
    } else {
      addHighlightForEntity(for: modelEntity)
    }
  }

  private func loadArrowEntity() {
    let arrowEntityRequest = ModelEntity.loadAsync(named: "Arrow")
    arrowEntityRequest
      .receive(on: DispatchQueue.main)
      .sink { result in
        switch result {
        case .failure(let error): print("Failed with error: \(error.localizedDescription)")
        case .finished: print("Successfully loaded Arrow")
        }
      } receiveValue: { [weak self] modelEntity in
        guard let self else { return }
        modelEntity.name = "Arrow"
        modelEntity.scale = [0.0002, 0.0002, 0.0002]
        modelEntity.position = [0, 0.1, 0]
        self.arrowEntity = modelEntity.clone(recursive: true)
        originalScale = modelEntity.scale(relativeTo: nil)
      }
      .store(in: &cancellables)
  }

  @objc func resetScene() {
    parent.arView.scene.anchors.removeAll()
    focusEntity = FocusEntity(on: parent.arView, style: .classic(color: accentColor))
    selectedEntity = nil
  }

  private func getExistingModelEntityClone() -> Entity? {
    guard let fileURL = parent.fileURL,
      let modelEntity = parent.arView.scene.findEntity(named: fileURL.absoluteString)
    else { return nil }
    return modelEntity.clone(recursive: true)
  }

  private func getEntityTransform(for focusTransform: simd_float4x4) -> float4x4 {
    let position = focusTransform.columns.3
    let horizontalRotation = simd_quatf(angle: 0, axis: [1, 0, 0])
    /// No X rotation
    let correctedTransform = float4x4(horizontalRotation)
    /// Only keep Y rotation
    /// Apply position while keeping only horizontal alignment
    var finalTransform = correctedTransform
    finalTransform.columns.3 = position
    return finalTransform/// Preserve position
  }

  private func hideShowFocusEntity() {
    if let focusEntity = parent.arView.scene.anchors.first(where: { $0.name == focusEntity?.name ?? "FocusEntity" }) {
      focusEntity.isEnabled.toggle()
    }
  }

  @objc private func snapshotAction() {
    let isEnabled = focusEntity?.isEnabled ?? false
    if isEnabled {
      hideShowFocusEntity()
    }
    parent.arView.snapshot(saveToHDR: false) { [weak self] (image) in
      guard let self else { return }
      // Compress the image
      guard let compressedImage = UIImage(data: (image?.pngData())!) else { return }
      // Save in the photo album
      UIImageWriteToSavedPhotosAlbum(compressedImage, nil, nil, nil)
      // TODO: - After saving show popup
      if isEnabled != focusEntity?.isEnabled {
        hideShowFocusEntity()
      }
    }
  }

  private func enableGestures(arView: ARView, for entity: Entity) {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    let panGesture = CustomPanGesture(target: self, action: #selector(handleCustomPan(_:)), entity: entity)
    let pinchGesture = CustomPinchGesture(target: self, action: #selector(handleCustomPinch(_:)), entity: entity)
    let rotationGesture = CustomPanGesture(target: self, action: #selector(handleTwoFingerPan(_:)), entity: entity)
    rotationGesture.minimumNumberOfTouches = 2
    rotationGesture.maximumNumberOfTouches = 2

    arView.addGestureRecognizer(tapGesture)
    arView.addGestureRecognizer(panGesture)
    arView.addGestureRecognizer(pinchGesture)
    arView.addGestureRecognizer(rotationGesture)
  }

  @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
    let touchLocation = gesture.location(in: parent.arView)
    guard let entity = parent.arView.entity(at: touchLocation) else { return }

    deleteHighlightedForEntity()
    addHighlightForEntity(for: entity)
    enableGestures(arView: parent.arView, for: entity)
    selectedEntity = entity
  }

  private func deleteHighlightedForEntity() {
    for anchor in parent.arView.scene.anchors {
      if let modelEntity = anchor.findEntity(named: "Arrow") {
        modelEntity.removeFromParent()
      }
    }
  }

  @objc private func deleteSelectedEntity() {
    if let anchorEntity = selectedEntity?.anchor {
      anchorEntity.removeFromParent()
    }
    selectedEntity = nil
  }

  private func addHighlightForEntity(for entity: Entity) {
    guard let arrowEntity, let originalScale,
      let meshResource = entity.components[ModelComponent.self]?.mesh
    else { return }
    let parentHeight = meshResource.bounds.extents.y
    arrowEntity.position = SIMD3(0, parentHeight + 0.05, 0)
    let scale = entity.scale
    arrowEntity.setScale(originalScale * scale, relativeTo: nil)
    entity.addChild(arrowEntity)

    guard arrowEntity.availableAnimations.count > 0,
      let animation = arrowEntity.availableAnimations.first
    else { return }
    arrowEntity.playAnimation(animation.repeat())
  }

  @objc private func handleTwoFingerPan(_ gesture: CustomPanGesture) {
    guard let entity = gesture.entity else { return }
    let translation = gesture.translation(in: gesture.view)
    let rotation3D = SIMD3<Float>(
      Float(translation.x),  // Horizontal movement
      Float(-translation.y),  // Vertical movement
      0
    )
    entity.rotate(in: rotation3D)
    gesture.setTranslation(.zero, in: gesture.view)
  }

  @objc private func handleCustomPan(_ gesture: CustomPanGesture) {
    guard let entity = gesture.entity else { return }
    let translation = gesture.translation(in: gesture.view)

    let translation3D = SIMD3<Float>(
      Float(translation.x) * 0.001,  // Left/Right
      Float(-translation.y) * 0.001,  // Up/Down
      0  // Forward/Backward
    )
    entity.translate(in: translation3D)
    gesture.setTranslation(.zero, in: gesture.view)
  }

  @objc private func handleCustomPinch(_ gesture: CustomPinchGesture) {
    guard let entity = gesture.entity else { return }
    let scale = Float(gesture.scale)
    entity.scale *= SIMD3<Float>(scale, scale, scale)
    gesture.scale = 1.0
  }

}

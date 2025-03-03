//
//  ARViewContainer.swift
//  ARLook
//
//  Created by Narek on 28.02.25.
//

import SwiftUI
import RealityKit
import FocusEntity
import ARKit
import Combine

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

  func makeCoordinator() -> Coordinator {
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

  class Coordinator: NSObject, ARSessionDelegate {

    @Binding var focusEntity: FocusEntity?
    @Binding var isLoading: Bool

    private var parent: ARViewContainer!
    private let accentColor: UIColor!
    private var cancellables = Set<AnyCancellable>()

    private lazy var directionalLight: Entity = {
      let lightEntity = Entity()
      var light = DirectionalLightComponent(color: .white, intensity: 3000) /// Adjust brightness
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
      parent.arView.session.pause()
    }

    func setupARView(_ arView: ARView, accentColor: UIColor) {
      arView.session.delegate = self

      setupSubviews(arView)

      NotificationCenter.default.addObserver(self, selector: #selector(placeModel), name: .placeModel, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(resetScene), name: .reset, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(snapshotAction), name: .snapshot, object: nil)
    }

    private func setupSubviews(_ arView: ARView) {
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        focusEntity = FocusEntity(on: arView, style: .classic(color: accentColor))
      }
    }

    @objc func placeModel() {
      guard let focusEntity = focusEntity, let fileURL = parent.fileURL else { return }
      let focusTransform = focusEntity.transformMatrix(relativeTo: nil)
      let finalTransform = getEntityTransform(for: focusTransform)
      isLoading = true
      if let modelEntity = getExistingModelEntityClone() {
        let anchorEntity = AnchorEntity(world: finalTransform)
        anchorEntity.addChild(modelEntity)
        parent.arView.scene.addAnchor(anchorEntity)
        isLoading = false
      } else {
        let modelEntityRequest = Entity.loadAsync(contentsOf: fileURL)
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
            let anchorEntity = AnchorEntity(world: finalTransform)
            anchorEntity.addChild(modelEntity)
            parent.arView.scene.addAnchor(anchorEntity)
            isLoading = false
          }
          .store(in: &cancellables)
      }
    }

    @objc func resetScene() {
      parent.arView.scene.anchors.removeAll()
      focusEntity = FocusEntity(on: parent.arView, style: .classic(color: accentColor))
    }

    private func getExistingModelEntityClone() -> Entity? {
      guard let fileURL = parent.fileURL,
        let modelEntity = parent.arView.scene.findEntity(named: fileURL.absoluteString)
      else { return nil }
      return modelEntity.clone(recursive: true)
    }

    private func getEntityTransform(for focusTransform: simd_float4x4) -> float4x4 {
      let position = focusTransform.columns.3
      let horizontalRotation = simd_quatf(angle: 0, axis: [1, 0, 0]) /// No X rotation
      let correctedTransform = float4x4(horizontalRotation) /// Only keep Y rotation
      /// Apply position while keeping only horizontal alignment
      var finalTransform = correctedTransform
      finalTransform.columns.3 = position
      /// Preserve position
      return finalTransform
    }

    private func hideShowFocusEntity() {
      if let focusEntity = parent.arView.scene.anchors.first(where: { $0.name == focusEntity?.name ?? "FocusEntity" }) {
        focusEntity.isEnabled.toggle()
      }
    }

    @objc func snapshotAction() {
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

  }

}

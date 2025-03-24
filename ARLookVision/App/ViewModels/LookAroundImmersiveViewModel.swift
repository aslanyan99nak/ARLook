//
//  LookAroundImmersiveViewModel.swift
//  ARLook
//
//  Created by Narek on 21.03.25.
//

import RealityKit
import SwiftUI

@MainActor
class LookAroundImmersiveViewModel: ObservableObject {

  @Published var selectedFileURL: URL?
  @Published var selectedModel: Model?

  private var contentEntity = ModelEntity()
  private var arrowEntity: Entity?
  private var originalScale: SIMD3<Float>?
  private var selectedEntity: Entity?

  init() {
    Task {
      await loadArrowEntity()
    }
  }

  func setupContentEntity() -> ModelEntity {
    contentEntity.components.set(InputTargetComponent())
    return contentEntity
  }

  func add(_ entity: Entity) {
    contentEntity.addChild(entity)
    guard entity.availableAnimations.count > 0,
      let animation = entity.availableAnimations.first
    else { return }
    entity.playAnimation(animation.repeat())
  }

  func getArrowEntity() -> Entity? {
    arrowEntity?.clone(recursive: true)
  }

  func getCurrentEntity() -> Entity? {
    selectedEntity?.clone(recursive: true)
  }

  func setCurrentEntity(_ entity: Entity) {
    selectedEntity = entity
    selectedEntity?.gestureComponent = setupGestureComponent(true)
  }

  func loadSelectedEntity() async {
    do {
      guard let selectedFileURL else { return }
      let entity = try await Entity(contentsOf: selectedFileURL)
      entity.name = selectedFileURL.absoluteString
      entity.gestureComponent = setupGestureComponent(true)
      let bounds = entity.visualBounds(relativeTo: nil)
      let size = bounds.extents
      let shapeResource = ShapeResource.generateBox(size: size)
      entity.components.set(CollisionComponent(shapes: [shapeResource]))
      entity.components.set(InputTargetComponent(allowedInputTypes: .all))
      self.selectedEntity = entity.clone(recursive: true)
    } catch {
      print("Failed with error: \(error.localizedDescription)")
    }
  }

  private func setupGestureComponent(_ gestureEnabled: Bool) -> GestureComponent {
    var gestureComponent = GestureComponent()
    gestureComponent.canDrag = gestureEnabled
    gestureComponent.canScale = gestureEnabled
    gestureComponent.canRotate = gestureEnabled
    return gestureComponent
  }

  func addHighlightForEntity(for entity: Entity) {
    guard let arrowEntity, let originalScale else { return }
    let bounds = entity.visualBounds(relativeTo: nil)
    let parentHeight = bounds.extents.y
    arrowEntity.position = SIMD3(0, parentHeight + 0.05, 0)
    let scale = entity.scale
    arrowEntity.setScale(originalScale * scale, relativeTo: nil)
    entity.addChild(arrowEntity)

    guard arrowEntity.availableAnimations.count > 0,
      let animation = arrowEntity.availableAnimations.first
    else { return }
    arrowEntity.playAnimation(animation.repeat())
  }

  func deleteHighlightedForEntity() {
    let gestureComponent = setupGestureComponent(false)
    setPropertyForAllChildren(of: contentEntity, component: gestureComponent)
    for entity in contentEntity.children {
      if let arrowEntity = entity.findEntity(named: "Arrow") {
        arrowEntity.removeFromParent()
      }
    }
  }

  func setPropertyForAllChildren(
    of entity: Entity,
    component: GestureComponent
  ) {
    entity.gestureComponent = component

    for child in entity.children {
      setPropertyForAllChildren(of: child, component: component)
    }
  }

  func deleteSelectedEntity() {
    selectedEntity?.removeFromParent()
  }

  private func loadArrowEntity() async {
    do {
      let modelEntity = try await Entity(named: "Arrow")
      modelEntity.name = "Arrow"
      modelEntity.scale = [0.0002, 0.0002, 0.0002]
      modelEntity.position = [0, 0.1, 0]
      self.arrowEntity = modelEntity.clone(recursive: true)
      originalScale = modelEntity.scale(relativeTo: nil)
    } catch {
      print("Failed with error: \(error.localizedDescription)")
    }
  }

  func resetContent() {
    contentEntity.children.removeAll()
  }

}

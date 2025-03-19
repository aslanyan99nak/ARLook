//
//  WorldScaningTrackingModel.swift
//  ARLook
//
//  Created by Narek on 10.03.25.
//

import ARKit
import Combine
import Foundation
import RealityKit
import SwiftUI

class TrackingModel: NSObject {

  var session: ARKitSession? = ARKitSession()
  var rootEntity = AnchorEntity(world: .zero)

//  func stop() {
//    session?.stop()
//    session = nil
//  }

}

class WorldScaningTrackingModel: TrackingModel, ObservableObject {
  
  @Published var material = UnlitMaterial(color: .red)
  @Published var selectedURL: URL?
  @Published var opacity: CGFloat = 1
  
  let sceneDataProvider = SceneReconstructionProvider(modes: [.classification])

  @MainActor
  func run() async {
    var providers: [DataProvider] = []
    if SceneReconstructionProvider.isSupported {
      providers.append(sceneDataProvider)
    }
//    stop()
//    session = ARKitSession()
    do {
      try await session?.run(providers)
      for await sceneUpdate in sceneDataProvider.anchorUpdates {
        let anchor = sceneUpdate.anchor
        let geometry = anchor.geometry
        switch sceneUpdate.event {
        case .added:
          // print classifications
          print("add anchor classification is \(String(describing: geometry.classifications))")
          try await createMeshEntity(geometry, anchor)
        case .updated:
          print("update")
          try await updateMeshEntity(geometry, anchor)
        case .removed:
          print("removed anchor classification is \(String(describing: geometry.classifications))")
          try removeMeshEntity(geometry, anchor)
        }
      }
    } catch {
      print("error is \(error)")
    }
  }

  @MainActor
  func createMeshEntity(_ geometry: MeshAnchor.Geometry, _ anchor: MeshAnchor) async throws {
    guard let modelEntity = try await generateModelEntity(geometry: geometry) else { return }
    let anchorEntity = AnchorEntity(world: anchor.originFromAnchorTransform)
    anchorEntity.addChild(modelEntity)
    anchorEntity.name = "MeshAnchor-\(anchor.id)"
    rootEntity.addChild(anchorEntity)
  }

  @MainActor
  func updateMeshEntity(_ geometry: MeshAnchor.Geometry, _ anchor: MeshAnchor) async throws {
    guard let modelEntity = try await generateModelEntity(geometry: geometry) else { return }
    if let anchorEntity = rootEntity.findEntity(named: "MeshAnchor-\(anchor.id)") {
      anchorEntity.children.removeAll()
      anchorEntity.addChild(modelEntity)
    }
  }

  func removeMeshEntity(_ geometry: MeshAnchor.Geometry, _ anchor: MeshAnchor) throws {
    if let anchorEntity = rootEntity.findEntity(named: "MeshAnchor-\(anchor.id)") {
      anchorEntity.removeFromParent()
    }
  }

  @MainActor
  func generateModelEntity(geometry: MeshAnchor.Geometry) async throws -> ModelEntity? {
    guard let meshResource = geometry.asMeshResource() else { return nil }
    let modelEntity = ModelEntity(mesh: meshResource, materials: [material])
    return modelEntity
  }
  
  @MainActor
  func saveModelEntity() {
    Task {
      await ModelManager.shared.saveFile(
        fileName: "Room.reality",
        entity: rootEntity
      ) { [weak self] isSuccess, url in
        DispatchQueue.main.async { [weak self] in
          guard let self else { return }
          if isSuccess {
            selectedURL = url
          }
        }
      }

    }
    
  }
  
}

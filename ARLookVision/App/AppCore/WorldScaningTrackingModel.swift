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

  @Published var material = SimpleMaterial(color: .red, isMetallic: false)
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

  // MARK: Geometry Mesh

  @MainActor
  func createMeshEntity(_ geometry: MeshAnchor.Geometry, _ anchor: MeshAnchor) async throws {
    let modelEntity = try await generateModelEntity(geometry: geometry)
    let anchorEntity = AnchorEntity(world: anchor.originFromAnchorTransform)
    anchorEntity.addChild(modelEntity)
    anchorEntity.name = "MeshAnchor-\(anchor.id)"
    rootEntity.addChild(anchorEntity)
  }

  @MainActor
  func updateMeshEntity(_ geometry: MeshAnchor.Geometry, _ anchor: MeshAnchor) async throws {
    let modelEntity = try await generateModelEntity(geometry: geometry)
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

  // MARK: Helpers

  @MainActor
  func generateModelEntity(geometry: MeshAnchor.Geometry) async throws -> ModelEntity {
    // generate mesh
    var desc = MeshDescriptor()
    let posValues = geometry.vertices.asSIMD3(ofType: Float.self)
    desc.positions = .init(posValues)
    let normalValues = geometry.normals.asSIMD3(ofType: Float.self)
    desc.normals = .init(normalValues)
    do {
      desc.primitives = .polygons(
        (0..<geometry.faces.count).map { _ in UInt8(3) },
        (0..<geometry.faces.count * 3).map {
          geometry.faces.buffer.contents()
            .advanced(by: $0 * geometry.faces.bytesPerIndex)
            .assumingMemoryBound(to: UInt32.self).pointee
        }
      )
    }
    let meshResource = try MeshResource.generate(from: [desc])
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

//
//  PlaneClassificationTrackingModel.swift
//  ARLook
//
//  Created by Narek on 14.03.25.
//

import ARKit
import Foundation
import RealityKit
import UIKit

class PlaneClassificationTrackingModel: TrackingModel, ObservableObject {

  let planeDataProvider = PlaneDetectionProvider(alignments: [.horizontal, .vertical])

  @Published var selectedURL: URL?

  @MainActor
  func run() async {
    var providers: [DataProvider] = []
    if PlaneDetectionProvider.isSupported {
      providers.append(planeDataProvider)
    }
    guard let session else { return }
    do {
      try await session.run(providers)
      for await sceneUpdate in planeDataProvider.anchorUpdates {
        try await updatePlaneEntity(sceneUpdate.anchor)
      }
    } catch {
      print("error is \(error)")
    }
  }

  @MainActor
  func updatePlaneEntity(_ anchor: PlaneAnchor) async throws {
    guard anchor.classification != .table,
      anchor.classification != .seat
    else { return }

    let modelEntity = try await generatePlanelExtent(anchor)
    let textEntity = await generatePlaneText(anchor)

    if let anchorEntity = rootEntity.findEntity(named: "PlaneAnchor-\(anchor.id)") {
      anchorEntity.children.removeAll()
      anchorEntity.addChild(modelEntity)
      anchorEntity.addChild(textEntity)
    } else {
      let anchorEntity = AnchorEntity(world: anchor.originFromAnchorTransform)
      anchorEntity.orientation = .init(angle: -.pi / 2, axis: .init(1, 0, 0))
      anchorEntity.addChild(modelEntity)
      anchorEntity.addChild(textEntity)
      anchorEntity.name = "PlaneAnchor-\(anchor.id)"
      rootEntity.addChild(anchorEntity)
    }
  }

  func removePlaneEntity(_ anchor: PlaneAnchor) throws {
    if let anchorEntity = rootEntity.findEntity(named: "PlaneAnchor-\(anchor.id)") {
      anchorEntity.removeFromParent()
    }
  }

  @MainActor
  func generatePlanelExtent(_ anchor: PlaneAnchor) async throws -> ModelEntity {
    // NOTE: extent in visionOS is on the geomerty object
    let extent = anchor.geometry.extent
//    var material = PhysicallyBasedMaterial()
//    let classificationColor = anchor.classificationColor
//    material.baseColor = .init(tint: classificationColor)
//    material.blending = .transparent(opacity: 0.7)
    
    
    let material = SimpleMaterial(
      color: anchor.classificationColor.withAlphaComponent(0.7),
      isMetallic: false
    )
    
    // Plane
    // TODO: - Change back to plane

//    let modelEntity = ModelEntity(
//      mesh: .generatePlane(
//        width: extent.width,
//        height: extent.height
//      ),
//      materials: [material]
//    )
    
    let modelEntity = ModelEntity(
      mesh: .generateBox(
        width: extent.width,
        height: extent.height,
        depth: 0.1
      ),
      materials: [material]
    )
    
    // NOTE: rotationOnYAxis is not avaliable on the visionOS
    // modelEntity.transform.rotation = .init(angle: extent.rotationOnYAxis, axis: .init(0, 1, 0))
    return modelEntity
  }

  @MainActor
  func generatePlaneText(_ anchor: PlaneAnchor) async -> ModelEntity {
    let classificationString = anchor.classificationString
    let textModelEntity = ModelEntity(
      mesh: .generateText(classificationString),
      materials: [SimpleMaterial(color: .black, isMetallic: false)]
    )
    textModelEntity.scale = simd_float3(repeating: 0.005)
    // NOTE: no center in visioin
    // textModelEntity.position = simd_float3(anchor.center.x, anchor.center.y, 0.5)
    return textModelEntity
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

extension PlaneAnchor {

  var classificationString: String {
    switch self.classification {
    case .unknown, .undetermined, .notAvailable: "Unknow"
    case .wall: "Wall"
    case .floor: "Floor"
    case .ceiling: "Celling"
    case .table: "Table"
    case .seat: "Seat"
    case .window: "Window"
    case .door: "Door"
    @unknown default: "Unknow"
    }
  }

  var classificationColor: UIColor {
    switch self.classification {
    case .unknown, .undetermined, .notAvailable: .red
    case .wall: .white
    case .floor: .brown
    case .ceiling: .white
    case .table: .orange
    case .seat: .black
    case .window: .blue
    case .door: .green
    @unknown default: .red
    }
  }

}

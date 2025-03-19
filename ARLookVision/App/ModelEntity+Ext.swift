//
//  ModelEntity+Ext.swift
//  ARLook
//
//  Created by Narek on 17.03.25.
//


import RealityKit
import SwiftUI
import ARKit

extension ModelEntity {
  
  class func createFingerTip(color: UIColor = .cyan, radius: Float = 0.006) -> ModelEntity {
    let entity = ModelEntity(
      mesh: .generateSphere(radius: radius),
      materials: [UnlitMaterial(color: color)],
      collisionShape: .generateSphere(radius: radius / 2),
      mass: 0
    )
    
    entity.components.set(PhysicsBodyComponent(mode: .kinematic))
    entity.components.set(OpacityComponent(opacity: 1))
    return entity
  }
  
}

extension ModelEntity {

  /// The geometry center of this model's faces.
  var centroid: SIMD3<Float>? {
    guard let vertices = self.model?.mesh.contents.models[0].parts[0].positions.elements else {
      return nil
    }
    guard let faces = self.model?.mesh.contents.models[0].parts[0].triangleIndices?.elements else {
      return nil
    }

    // Create a set of all vertices of the entity's faces.
    let uniqueFaces = Set(faces)

    var centroid = SIMD3<Float>()
    for vertexInFace in uniqueFaces {
      centroid += vertices[Int(vertexInFace)]
    }
    centroid /= Float(uniqueFaces.count)
    return centroid
  }

}

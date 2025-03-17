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
  
  class func createFingerTip() -> ModelEntity {
    let entity = ModelEntity(
      mesh: .generateSphere(radius: 0.01),
      materials: [UnlitMaterial(color: .cyan)],
      collisionShape: .generateSphere(radius: 0.005),
      mass: 0
    )
    
    entity.components.set(PhysicsBodyComponent(mode: .kinematic))
    entity.components.set(OpacityComponent(opacity: 0.1))
    return entity
  }
  
}

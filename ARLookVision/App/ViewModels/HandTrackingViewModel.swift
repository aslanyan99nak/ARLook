//
//  HandTrackingViewModel.swift
//  ARLook
//
//  Created by Narek on 17.03.25.
//

import ARKit
import Foundation
import RealityKit
import SwiftUI

@MainActor
class HandTrackingViewModel: ObservableObject {

  private let session = ARKitSession()
  private let handTracking = HandTrackingProvider()
  private let sceneReconstruction = SceneReconstructionProvider()
  private var contentEntity = Entity()
  private var meshEntities = [UUID: ModelEntity]()

  // Dictionary to track all fingers for both left and right hands
  private var fingerEntities: [HandAnchor.Chirality: [HandSkeleton.JointName: ModelEntity]] = [
    .left: [:],
    .right: [:],
  ]

  private var lastPlacementTime: TimeInterval = 0
  
  private var isFingersPlaced: Bool {
    guard let leftValues = fingerEntities[.left]?.values, leftValues.isEmpty,
          let rightValues = fingerEntities[.right]?.values, rightValues.isEmpty
    else { return true }
    return false
  }
  
  func setupContentEntity() -> Entity? {
    guard !isFingersPlaced else { return contentEntity }

    for key in fingerEntities.keys {
      if key == .left {
        setupJoints(for: key)
      } else {
        setupJoints(for: key)
      }
    }
    
    for hand in fingerEntities.values {
      for entity in hand.values {
        contentEntity.addChild(entity)
      }
    }
    contentEntity.components.set(InputTargetComponent())
    hideShowHandTracking(UserDefaults.isHandTrackingEnabled)
    return contentEntity
  }
  
  private func setupJoints(for chirality: HandAnchor.Chirality) {
    var leftJointsDictionary: [HandSkeleton.JointName: ModelEntity] = [:]
    
    HandSkeleton.JointName.allCases.forEach { jointName in
      var jointEntity: ModelEntity?
      if jointName == .wrist {
        jointEntity = ModelEntity.createFingerTip(color: .red, radius: 0.01)
      } else {
        let color: UIColor = chirality == .left ? .cyan : .purple
        jointEntity = ModelEntity.createFingerTip(color: color)
      }
      if let jointEntity {
        jointEntity.name = jointName.description
        let shape = ShapeResource.generateSphere(radius: 0.008)
        jointEntity.components.set(CollisionComponent(shapes: [shape]))
        leftJointsDictionary[jointName] = jointEntity
      }
    }
    
    fingerEntities[chirality] = leftJointsDictionary
  }

  func runSession() async {
    do {
      try await session.run([sceneReconstruction, handTracking])
    } catch {
      print("Failed to start session: \(error)")
    }
  }

  func processHandUpdates() async {
    for await update in handTracking.anchorUpdates {
      let handAnchor = update.anchor
      guard handAnchor.isTracked,
        let handSkeleton = handAnchor.handSkeleton
      else { continue }

      let originFromWrist = handAnchor.originFromAnchorTransform

      // Update all fingers for this hand
      for (jointName, entity) in fingerEntities[handAnchor.chirality] ?? [:] {
        let joint = handSkeleton.joint(jointName)
        if joint.isTracked {
          let jointTransform = joint.anchorFromJointTransform
          let worldTransform = originFromWrist * jointTransform
          entity.setTransformMatrix(worldTransform, relativeTo: nil)
        }
      }
    }
  }
  
  func placeCube() async {
    guard let indexFingerTipEntity = fingerEntities[.left]?[.indexFingerTip] else { return }
    let leftFingerPosition = indexFingerTipEntity.transform.translation
    let placementLocation = leftFingerPosition + SIMD3<Float>(0, -0.05, 0)

    let entity = ModelEntity(
      mesh: .generateBox(size: 0.1),
      materials: [SimpleMaterial(color: .systemBlue, isMetallic: false)],
      collisionShape: .generateBox(size: SIMD3<Float>(repeating: 0.1)),
      mass: 1.0
    )
    entity.setPosition(placementLocation, relativeTo: nil)
    entity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
    entity.components.set(GroundingShadowComponent(castsShadow: true))

    let material = PhysicsMaterialResource.generate(friction: 0.8, restitution: 0.0)
    entity.components.set(
      PhysicsBodyComponent(
        shapes: entity.collision?.shapes ?? [],
        mass: 1.0,
        material: material,
        mode: .dynamic
      )
    )
    contentEntity.addChild(entity)
  }
  
  func getLeftFingerPosition() -> SIMD3<Float>? {
    guard let indexFingerTipEntity = fingerEntities[.left]?[.indexFingerTip]
    else { return nil }
    let leftFingerPosition = indexFingerTipEntity.transform.translation
    let placementLocation = leftFingerPosition + SIMD3<Float>(0, -0.05, 0)
    return placementLocation
  }

  func hideShowHandTracking(_ enabled: Bool) {
    fingerEntities.values.forEach { $0.values.forEach { $0.isEnabled = enabled } }
  }
  
}

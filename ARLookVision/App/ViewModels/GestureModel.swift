//
//  GestureModel.swift
//  ARLook
//
//  Created by Narek on 20.03.25.
//

import ARKit
import SwiftUI

enum GestureType {

  case tap
  case middleTap
  case heart
  case custom
  case cross
  case unknown

  var gestureCooldown: TimeInterval {
    switch self {
    case .tap: 0.5
    case .middleTap: 0.5
    case .heart: 4.0
    case .custom: 2.0
    case .cross: 1.0
    case .unknown: 0.0
    }
  }

}

/// A model that contains up-to-date hand coordinate information and handles heart gesture actions.
@MainActor
class GestureModel: ObservableObject, @unchecked Sendable {

  @Published var latestHandTracking: HandsUpdates = .init(left: nil, right: nil)

  let session = ARKitSession()
  var handTracking = HandTrackingProvider()
  var gestureAction: (GestureType) -> Void = { _ in }
  private var gestureLastTimes: [GestureType: Date] = [:]
  private var currentGestureType: GestureType = .unknown

  struct HandsUpdates {

    var left: HandAnchor?
    var right: HandAnchor?

  }

  func start() async {
    do {
      if HandTrackingProvider.isSupported {
        print("ARKitSession starting.")
        try await session.run([handTracking])
      }
    } catch {
      print("ARKitSession error:", error)
    }
  }

  func publishHandTrackingUpdates() async {
    for await update in handTracking.anchorUpdates {
      switch update.event {
      case .updated:
        let anchor = update.anchor
        guard anchor.isTracked else { continue }
        if anchor.chirality == .left {
          latestHandTracking.left = anchor
        } else if anchor.chirality == .right {
          latestHandTracking.right = anchor
        }
        performGestureDetection()
      default: break
      }
    }
  }

  private func performGestureDetection() {
    if isHeartGestureDetected() && currentGestureType != .heart {
      currentGestureType = .heart
      performHeartGestureAction()
    } else if isMyCustomGestureDetected() && currentGestureType != .custom {
      currentGestureType = .custom
      performCustomGestureAction()
    } else if isMiddleTapDetected() {
      currentGestureType = .middleTap
      performMiddleTapGestureAction()
    } else if isSimpleTapDetected() {
      currentGestureType = .tap
      performSimpleTapGestureAction()
    } else if isCrossGestureDetected() {
      currentGestureType = .cross
      performCrossGestureAction()
    } else {
      currentGestureType = .unknown
    }
  }

  func isHeartGestureDetected() -> Bool {
    guard let leftHandAnchor = latestHandTracking.left,
      let rightHandAnchor = latestHandTracking.right,
      leftHandAnchor.isTracked, rightHandAnchor.isTracked,
      let leftHandThumbTip = leftHandAnchor.handSkeleton?.joint(.thumbTip),
      let leftHandIndexTip = leftHandAnchor.handSkeleton?.joint(.indexFingerTip),
      let rightHandThumbTip = rightHandAnchor.handSkeleton?.joint(.thumbTip),
      let rightHandIndexTip = rightHandAnchor.handSkeleton?.joint(.indexFingerTip),
      leftHandThumbTip.isTracked, leftHandIndexTip.isTracked,
      rightHandThumbTip.isTracked, rightHandIndexTip.isTracked
    else {
      return false
    }

    let leftThumbPosition = matrix_multiply(
      leftHandAnchor.originFromAnchorTransform, leftHandThumbTip.anchorFromJointTransform
    ).columns.3.xyz
    let rightThumbPosition = matrix_multiply(
      rightHandAnchor.originFromAnchorTransform, rightHandThumbTip.anchorFromJointTransform
    ).columns.3.xyz
    let leftIndexPosition = matrix_multiply(
      leftHandAnchor.originFromAnchorTransform, leftHandIndexTip.anchorFromJointTransform
    ).columns.3.xyz
    let rightIndexPosition = matrix_multiply(
      rightHandAnchor.originFromAnchorTransform, rightHandIndexTip.anchorFromJointTransform
    ).columns.3.xyz

    let thumbDistance = distance(leftThumbPosition, rightThumbPosition)
    let indexDistance = distance(leftIndexPosition, rightIndexPosition)

    return thumbDistance < 0.01 && indexDistance < 0.01
  }

  func isSimpleTapDetected() -> Bool {
    guard let rightHandAnchor = latestHandTracking.right,
      rightHandAnchor.isTracked,
      let rightHandIndexTip = rightHandAnchor.handSkeleton?.joint(.indexFingerTip),
      let rightHandThumbTip = rightHandAnchor.handSkeleton?.joint(.thumbTip),
      rightHandIndexTip.isTracked, rightHandThumbTip.isTracked
    else {
      return false
    }

    let rightThumbPosition = matrix_multiply(
      rightHandAnchor.originFromAnchorTransform, rightHandThumbTip.anchorFromJointTransform
    ).columns.3.xyz

    let rightIndexPosition = matrix_multiply(
      rightHandAnchor.originFromAnchorTransform, rightHandIndexTip.anchorFromJointTransform
    ).columns.3.xyz
    let tapDistance = distance(rightThumbPosition, rightIndexPosition)
    return tapDistance < 0.01
  }

  func isMiddleTapDetected() -> Bool {
    guard let rightHandAnchor = latestHandTracking.right,
      rightHandAnchor.isTracked,
      let rightHandMiddleTip = rightHandAnchor.handSkeleton?.joint(.middleFingerTip),
      let rightHandThumbTip = rightHandAnchor.handSkeleton?.joint(.thumbTip),
      rightHandMiddleTip.isTracked, rightHandThumbTip.isTracked
    else {
      return false
    }

    let rightThumbPosition = matrix_multiply(
      rightHandAnchor.originFromAnchorTransform, rightHandThumbTip.anchorFromJointTransform
    ).columns.3.xyz

    let rightMiddleTipPosition = matrix_multiply(
      rightHandAnchor.originFromAnchorTransform, rightHandMiddleTip.anchorFromJointTransform
    ).columns.3.xyz
    let tapDistance = distance(rightThumbPosition, rightMiddleTipPosition)
    return tapDistance < 0.01
  }

  func isMyCustomGestureDetected() -> Bool {
    guard let leftHandAnchor = latestHandTracking.left,
      let rightHandAnchor = latestHandTracking.right,
      leftHandAnchor.isTracked, rightHandAnchor.isTracked,
      let leftHandLittleFingerTip = leftHandAnchor.handSkeleton?.joint(.littleFingerTip),
      let rightHandThumbTip = rightHandAnchor.handSkeleton?.joint(.thumbTip),
      let rightHandRingFingerTip = rightHandAnchor.handSkeleton?.joint(.ringFingerTip),
      leftHandLittleFingerTip.isTracked,
      rightHandThumbTip.isTracked, rightHandRingFingerTip.isTracked
    else {
      return false
    }

    let leftLittleFingerTipPosition = matrix_multiply(
      leftHandAnchor.originFromAnchorTransform, leftHandLittleFingerTip.anchorFromJointTransform
    ).columns.3.xyz

    let rightThumbPosition = matrix_multiply(
      rightHandAnchor.originFromAnchorTransform, rightHandThumbTip.anchorFromJointTransform
    ).columns.3.xyz
    let rightRingFingerTipPosition = matrix_multiply(
      rightHandAnchor.originFromAnchorTransform, rightHandRingFingerTip.anchorFromJointTransform
    ).columns.3.xyz

    let thumbToLittleFingerTipDistance = distance(leftLittleFingerTipPosition, rightThumbPosition)
    let ringFingerTipToLittleFingerTipDistance = distance(leftLittleFingerTipPosition, rightRingFingerTipPosition)

    return thumbToLittleFingerTipDistance < 0.01 && ringFingerTipToLittleFingerTipDistance < 0.01
  }

  func isCrossGestureDetected() -> Bool {
    guard let leftHandAnchor = latestHandTracking.left,
      let rightHandAnchor = latestHandTracking.right,
      leftHandAnchor.isTracked, rightHandAnchor.isTracked,

      let leftHandIndexFingerIntermediateBase = leftHandAnchor.handSkeleton?.joint(.indexFingerIntermediateBase),
      let rightHandIndexFingerIntermediateBase = rightHandAnchor.handSkeleton?.joint(.indexFingerIntermediateBase),
      leftHandIndexFingerIntermediateBase.isTracked, rightHandIndexFingerIntermediateBase.isTracked
    else {
      return false
    }

    let leftIndexFingerIntermediateBasePosition = matrix_multiply(
      leftHandAnchor.originFromAnchorTransform, leftHandIndexFingerIntermediateBase.anchorFromJointTransform
    ).columns.3.xyz

    let rightIndexFingerIntermediateBasePosition = matrix_multiply(
      rightHandAnchor.originFromAnchorTransform, rightHandIndexFingerIntermediateBase.anchorFromJointTransform
    ).columns.3.xyz

    let crossDistance = distance(leftIndexFingerIntermediateBasePosition, rightIndexFingerIntermediateBasePosition)

    return crossDistance < 0.02
  }

  func performHeartGestureAction() {
    let now = Date()
    if let lastTime = gestureLastTimes[.heart],
      now.timeIntervalSince(lastTime) < GestureType.heart.gestureCooldown
    {
      return/// Cooldown period, ignore repeated gestures
    }

    gestureLastTimes[.heart] = now
    print("❤️ Heart gesture detected! Performing action...")
    gestureAction(.heart)
  }

  func performSimpleTapGestureAction() {
    let now = Date()
    if let lastTime = gestureLastTimes[.tap],
      now.timeIntervalSince(lastTime) < GestureType.tap.gestureCooldown
    {
      return
    }

    gestureLastTimes[.tap] = now
    print("👌🏻 Tap gesture detected! Performing action...")
    gestureAction(.tap)
  }

  func performMiddleTapGestureAction() {
    let now = Date()
    if let lastTime = gestureLastTimes[.middleTap],
      now.timeIntervalSince(lastTime) < GestureType.middleTap.gestureCooldown
    {
      return
    }

    gestureLastTimes[.middleTap] = now
    print("🤞🏻 Middle Tap gesture detected! Performing action...")
    gestureAction(.middleTap)
  }

  func performCustomGestureAction() {
    let now = Date()
    if let lastTime = gestureLastTimes[.custom],
      now.timeIntervalSince(lastTime) < GestureType.custom.gestureCooldown
    {
      return
    }

    gestureLastTimes[.custom] = now
    print("👌🏻 Custom gesture detected! Performing action...")
    gestureAction(.custom)
  }
  
  func performCrossGestureAction() {
    let now = Date()
    if let lastTime = gestureLastTimes[.cross],
      now.timeIntervalSince(lastTime) < GestureType.cross.gestureCooldown
    {
      return
    }

    gestureLastTimes[.cross] = now
    print("❌ Cross gesture detected! Performing action...")
    gestureAction(.cross)
  }

}

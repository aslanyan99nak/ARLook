//
//  CustomGesture.swift
//  ARLook
//
//  Created by Narek on 03.03.25.
//

import RealityKit
import UIKit

class CustomPanGesture: UIPanGestureRecognizer {

  var entity: Entity?

  init(target: Any?, action: Selector?, entity: Entity) {
    self.entity = entity
    super.init(target: target, action: action)
  }

}

class CustomPinchGesture: UIPinchGestureRecognizer {

  var entity: Entity?

  init(target: Any?, action: Selector?, entity: Entity) {
    self.entity = entity
    super.init(target: target, action: action)
  }

}

class CustomRotationGesture: UIRotationGestureRecognizer {

  var entity: Entity?

  init(target: Any?, action: Selector?, entity: Entity) {
    self.entity = entity
    super.init(target: target, action: action)
  }

}

//
//  RealityView+Ext.swift
//  ARLook
//
//  Created by Narek on 24.03.25.
//

import RealityKit
import SwiftUI

extension RealityView {

  func installGestures() -> some View {
    simultaneousGesture(dragGesture)
      .simultaneousGesture(magnifyGesture)
      .simultaneousGesture(rotateGesture)
  }

  var dragGesture: some Gesture {
    DragGesture()
      .targetedToAnyEntity()
      .useGestureComponent()
  }

  var magnifyGesture: some Gesture {
    MagnifyGesture()
      .targetedToAnyEntity()
      .useGestureComponent()
  }

  var rotateGesture: some Gesture {
    RotateGesture3D()
      .targetedToAnyEntity()
      .useGestureComponent()
  }
}

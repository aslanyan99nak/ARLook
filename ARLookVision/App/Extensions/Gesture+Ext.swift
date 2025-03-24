//
//  Gesture+Ext.swift
//  ARLook
//
//  Created by Narek on 24.03.25.
//

import RealityKit
import SwiftUI

/// Gesture extension to support rotation gestures.
extension Gesture where Value == EntityTargetValue<RotateGesture3D.Value> {

  /// Connects the gesture input to the `GestureComponent` code.
  public func useGestureComponent() -> some Gesture {
    onChanged { value in
      guard var gestureComponent = value.entity.gestureComponent else { return }
      gestureComponent.onChanged(value: value)
      value.entity.components.set(gestureComponent)
    }
    .onEnded { value in
      guard var gestureComponent = value.entity.gestureComponent else { return }
      gestureComponent.onEnded(value: value)
      value.entity.components.set(gestureComponent)
    }
  }
}

/// Gesture extension to support drag gestures.
extension Gesture where Value == EntityTargetValue<DragGesture.Value> {

  /// Connects the gesture input to the `GestureComponent` code.
  public func useGestureComponent() -> some Gesture {
    onChanged { value in
      guard var gestureComponent = value.entity.gestureComponent else { return }
      gestureComponent.onChanged(value: value)
      value.entity.components.set(gestureComponent)
    }
    .onEnded { value in
      guard var gestureComponent = value.entity.gestureComponent else { return }
      gestureComponent.onEnded(value: value)
      value.entity.components.set(gestureComponent)
    }
  }
}

/// Gesture extension to support scale gestures.
extension Gesture where Value == EntityTargetValue<MagnifyGesture.Value> {

  /// Connects the gesture input to the `GestureComponent` code.
  public func useGestureComponent() -> some Gesture {
    onChanged { value in
      guard var gestureComponent = value.entity.gestureComponent else { return }
      gestureComponent.onChanged(value: value)
      value.entity.components.set(gestureComponent)
    }
    .onEnded { value in
      guard var gestureComponent = value.entity.gestureComponent else { return }
      gestureComponent.onEnded(value: value)
      value.entity.components.set(gestureComponent)
    }
  }
}

//
//  Entity+Ext.swift
//  ARLook
//
//  Created by Narek on 24.03.25.
//

import RealityKit
import SwiftUI

extension Entity {

  public var gestureComponent: GestureComponent? {
    get { components[GestureComponent.self] }
    set { components[GestureComponent.self] = newValue }
  }

  /// Returns the position of the entity specified in the app's coordinate system. On
  /// iOS and macOS, which don't have a device native coordinate system, scene
  /// space is often referred to as "world space".
  public var scenePosition: SIMD3<Float> {
    get { position(relativeTo: nil) }
    set { setPosition(newValue, relativeTo: nil) }
  }

  /// Returns the orientation of the entity specified in the app's coordinate system. On
  /// iOS and macOS, which don't have a device native coordinate system, scene
  /// space is often referred to as "world space".
  public var sceneOrientation: simd_quatf {
    get { orientation(relativeTo: nil) }
    set { setOrientation(newValue, relativeTo: nil) }
  }

}

//
//  UIDevice+Ext.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import UIKit

#if !os(visionOS)
import ARKit
#endif

extension UIDevice {

  static let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad

  static let isVision: Bool = UIDevice.current.userInterfaceIdiom == .vision

  #if !os(visionOS)
  static let hasLiDAR: Bool = ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
  #endif

}

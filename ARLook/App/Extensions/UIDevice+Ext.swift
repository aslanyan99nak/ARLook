//
//  UIDevice+Ext.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import UIKit
import ARKit

extension UIDevice {
  
  static let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
  
  static let hasLiDAR: Bool = ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
  
}

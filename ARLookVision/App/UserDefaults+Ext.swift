//
//  UserDefaults+Ext.swift
//  ARLook
//
//  Created by Narek on 19.03.25.
//

import Foundation

extension UserDefaults {

  static var isHandTrackingEnabled: Bool {
    get { UserDefaults.standard.bool(forKey: "isHandTrackingEnabled") }
    set { UserDefaults.standard.set(newValue, forKey: "isHandTrackingEnabled") }
  }

}

//
//  ARLookApp.swift
//  ARLook
//
//  Created by Narek Aslanyan on 30.01.25.
//

import SwiftUI

@main
struct ARLookApp: App {
  
  static let subsystem: String = "com.nak.ARLook"

  var body: some Scene {
    WindowGroup {
      MainTabBar()
    }
  }

}

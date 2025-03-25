//
//  ARLookApp.swift
//  ARLook
//
//  Created by Narek Aslanyan on 30.01.25.
//

import SwiftUI
import Nuke

@main
struct ARLookApp: App {
  
  @Environment(\.scenePhase) var scenePhase

  var body: some Scene {
    WindowGroup {
      MainTabBar()
        .onChange(of: scenePhase) { _, newPhase in
          if newPhase == .active {
            ImagePipeline.shared = ImagePipeline(configuration: .withDataCache)
          }
        }
    }
  }

}

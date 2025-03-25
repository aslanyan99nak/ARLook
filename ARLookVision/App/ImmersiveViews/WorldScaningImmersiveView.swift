//
//  WorldScaningImmersiveView.swift
//  ARLook
//
//  Created by Narek on 13.03.25.
//

import RealityKit
import SwiftUI

struct WorldScaningImmersiveView: View {

  @EnvironmentObject var model: WorldScaningTrackingModel
  @EnvironmentObject var appModel: AppModel
  @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

  var body: some View {
    RealityView { content in
      content.add(model.rootEntity)
    }
    .task {
      await model.run()
    }
    .onDisappear {
      Task {
        if appModel.immersiveSpaceId != nil {
          await dismissImmersiveSpace()
          appModel.immersiveSpaceId = nil
        }
        // model.resetContent()
      }
    }
  }

}

#Preview {
  WorldScaningImmersiveView()
}

//
//  PlaneClassificationImmersiveView.swift
//  ARLook
//
//  Created by Narek on 14.03.25.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct PlaneClassificationImmersiveView: View {
  
  @EnvironmentObject var model: PlaneClassificationTrackingModel
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
  PlaneClassificationImmersiveView()
}

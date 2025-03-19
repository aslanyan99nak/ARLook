//
//  LookAroundScreen.swift
//  ARLook
//
//  Created by Narek on 17.03.25.
//

import RealityKit
import SwiftUI

struct LookAroundScreen: View {

  @EnvironmentObject var mainCameraTrackingModel: MainCameraTrackingModel
  @EnvironmentObject var appModel: AppModel
  @Environment(\.openImmersiveSpace) var openImmersiveSpace
  @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

  var body: some View {
    VStack(spacing: 40) {
      openDismissMainCameraButton
    }
  }

  private var openDismissMainCameraButton: some View {
    Button {
      Task {
        if appModel.immersiveSpaceId != nil {
          await dismissImmersiveSpace()
          appModel.immersiveSpaceId = nil
        } else {
          await openImmersiveSpace(id: ShowCase.mainCamera.immersiveSpaceId)
          appModel.immersiveSpaceId = ShowCase.mainCamera.immersiveSpaceId
        }
      }
    } label: {
      Text(appModel.immersiveSpaceId != nil ? "Dismiss MainCamera" : "Show MainCamera")
    }
  }

}

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
  @EnvironmentObject var immersiveModel: ImmersiveModel
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
        if immersiveModel.immersiveSpaceId != nil {
          await dismissImmersiveSpace()
          immersiveModel.immersiveSpaceId = nil
        } else {
          await openImmersiveSpace(id: ShowCase.mainCamera.immersiveSpaceId)
          immersiveModel.immersiveSpaceId = ShowCase.mainCamera.immersiveSpaceId
        }
      }
    } label: {
      Text(immersiveModel.immersiveSpaceId != nil ? "Dismiss MainCamera" : "Show MainCamera")
    }
  }

}

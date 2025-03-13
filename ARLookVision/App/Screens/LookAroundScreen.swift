//
//  LookAroundScreen.swift
//  ARLook
//
//  Created by Narek on 13.03.25.
//

import SwiftUI

struct LookAroundScreen: View {

  @EnvironmentObject var model: WorldScaningTrackingModel
  @EnvironmentObject var immseriveModel: ImmersiveModel
  @Environment(\.openImmersiveSpace) var openImmersiveSpace
  @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
  @Environment(\.openWindow) var openWindow
  @Environment(\.dismissWindow) var dismissWindow

  @State private var previewURL: URL?

  var body: some View {
    VStack(spacing: 40) {
      openDismissImmersiveSpaceButton
      previewButton
      selectMaterialButton
    }
    .onDisappear {
      if immseriveModel.immersiveSpaceId != nil {
        Task {
          await dismissImmersiveSpace()
          immseriveModel.immersiveSpaceId = nil
        }
      }
    }
  }

  private var openDismissImmersiveSpaceButton: some View {
    Button {
      Task {
        if immseriveModel.immersiveSpaceId != nil {
          await dismissImmersiveSpace()
          immseriveModel.immersiveSpaceId = nil
        } else {
          await openImmersiveSpace(id: "WorldScaning")
          immseriveModel.immersiveSpaceId = "WorldScaning"
        }
      }
    } label: {
      Text(immseriveModel.immersiveSpaceId != nil ? "Dismiss Immersive Space" : "Show Meshes")
    }
  }

  private var previewButton: some View {
    Button {
      previewURL = model.selectedURL
    } label: {
      Text("View as a 3D")
    }
    .quickLookPreview($previewURL)
  }

  private var selectMaterialButton: some View {
    Button {
      if immseriveModel.windowId.isNotNil && immseriveModel.windowId == "ChangeMaterialColor" {
        dismissWindow(id: "ChangeMaterialColor")
      } else {
        openWindow(id: "ChangeMaterialColor")
      }
    } label: {
      Text("Select Material")
    }
  }

}


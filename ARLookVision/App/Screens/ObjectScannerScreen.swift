//
//  ObjectScannerScreen.swift
//  ARLook
//
//  Created by Narek on 13.03.25.
//

import SwiftUI

struct ObjectScannerScreen: View {

  @EnvironmentObject var model: WorldScaningTrackingModel
  @EnvironmentObject var planeClassificationModel: PlaneClassificationTrackingModel
  @EnvironmentObject var immseriveModel: ImmersiveModel
  @Environment(\.openImmersiveSpace) var openImmersiveSpace
  @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
  @Environment(\.openWindow) var openWindow
  @Environment(\.dismissWindow) var dismissWindow

  @State private var previewURL: URL?

  var body: some View {
    VStack(spacing: 40) {
      openDismissImmersiveSpaceButton
      openDismissPlaneClassificationSpaceButton
      wallScannerView
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
          await openImmersiveSpace(id: ShowCase.worldScaning.immersiveSpaceId)
          immseriveModel.immersiveSpaceId = ShowCase.worldScaning.immersiveSpaceId
        }
      }
    } label: {
      Text(immseriveModel.immersiveSpaceId != nil ? "Dismiss Immersive Space" : "Show Meshes")
    }
  }

  private var previewButton: some View {
    Button {
      // TODO: - Change back

//      previewURL = model.selectedURL
      previewURL = planeClassificationModel.selectedURL
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
  
  private var openDismissPlaneClassificationSpaceButton: some View {
    Button {
      Task {
        if immseriveModel.immersiveSpaceId != nil {
          await dismissImmersiveSpace()
          immseriveModel.immersiveSpaceId = nil
        } else {
          await openImmersiveSpace(id: ShowCase.planeClassification.immersiveSpaceId)
          immseriveModel.immersiveSpaceId = ShowCase.planeClassification.immersiveSpaceId
        }
      }
    } label: {
      Text(immseriveModel.immersiveSpaceId != nil ? "Dismiss PlaneClassification Space" : "Show PlaneClassification Space")
    }
  }
  
  private var wallScannerView: some View {
    RoomTrackingScreen()
  }

}


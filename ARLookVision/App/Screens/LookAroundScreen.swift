//
//  LookAroundScreen.swift
//  ARLook
//
//  Created by Narek on 17.03.25.
//

import RealityKit
import SwiftUI

struct LookAroundScreen: View {

  @AppStorage("isHandTrackingEnabled") var isHandTrackingEnabled: Bool = false
  @EnvironmentObject var appModel: AppModel
  @EnvironmentObject var lookAroundViewModel: LookAroundImmersiveViewModel
  @EnvironmentObject var handTracking: HandTrackingViewModel
  @Environment(\.openImmersiveSpace) var openImmersiveSpace
  @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
  @Environment(\.openWindow) var openWindow
  @Environment(\.dismissWindow) var dismissWindow

  var body: some View {
    VStack(spacing: 40) {
      openDismissMainCameraButton
      if isHandTrackingEnabled,
        appModel.immersiveSpaceId == ShowCase.lookAround.immersiveSpaceId
      {
        addEntityButton
        selectEntityButton
      }
    }
    .onChange(of: lookAroundViewModel.selectedModel) { oldValue, newValue in
      if newValue.isNotNil {
        guard appModel.windowId.isNotNil,
          appModel.windowId == WindowCase.searchScreen.rawValue
        else { return }
        dismissWindow(id: WindowCase.searchScreen.rawValue)
        appModel.windowId = nil
        Task {
          await lookAroundViewModel.loadSelectedEntity()
        }
      }
    }
  }

  private var openDismissMainCameraButton: some View {
    Button {
      Task {
        if appModel.immersiveSpaceId != nil {
          await dismissImmersiveSpace()
          appModel.immersiveSpaceId = nil
        } else {
          await openImmersiveSpace(id: ShowCase.lookAround.immersiveSpaceId)
          appModel.immersiveSpaceId = ShowCase.lookAround.immersiveSpaceId
        }
      }
    } label: {
      Text(appModel.immersiveSpaceId != nil ? "Dismiss Immersinve" : "Show Immersive")
    }
  }

  private var addEntityButton: some View {
    Button {
      guard let arrowEntity = lookAroundViewModel.getArrowEntity(),
        let placementLocation = handTracking.getLeftFingerPosition()
      else { return }
      arrowEntity.setPosition(placementLocation, relativeTo: nil)
      arrowEntity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
      lookAroundViewModel.add(arrowEntity)
    } label: {
      Text("Add Entity")
    }
  }

  private var selectEntityButton: some View {
    Button {
      if appModel.windowId.isNotNil {
        if appModel.windowId == WindowCase.searchScreen.rawValue {
          dismissWindow(id: WindowCase.searchScreen.rawValue)
          appModel.windowId = nil
        }
      } else {
        openWindow(id: WindowCase.searchScreen.rawValue)
        appModel.windowId = WindowCase.searchScreen.rawValue
      }
    } label: {
      Text("Choose Entity")
    }
  }

}

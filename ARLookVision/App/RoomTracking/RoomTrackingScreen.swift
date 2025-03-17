//
//  RoomTrackingScreen.swift
//  ARLook
//
//  Created by Narek on 17.03.25.
//

import RealityKit
import SwiftUI

struct RoomTrackingScreen: View {

  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.openImmersiveSpace) var openImmersiveSpace
  @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
  @Environment(RoomState.self) var roomState
  @EnvironmentObject var roomClassificationTrackingModel: RoomClassificationTrackingModel
  @State private var previewURL: URL?

  var body: some View {
    Group {
      if roomState.errorState != .noError {
        errorView
      } else if roomState.isImmersive {
        viewWhileImmersed
      } else {
        viewWhileNonImmersed
      }
    }
    .padding()
    .frame(width: 600)
    .onChange(of: scenePhase) {
      if scenePhase != .active && roomState.isImmersive {
        Task {
          await dismissImmersiveSpace()
          roomState.isImmersive = false
        }
      }
    }
    .onChange(of: roomState.errorState) {
      if roomState.errorState != .noError && roomState.isImmersive {
        Task {
          await dismissImmersiveSpace()
          roomState.isImmersive = false
        }
      }
    }
  }

  @MainActor
  var viewWhileNonImmersed: some View {
    VStack(spacing: 16) {
      Text("Enter the immersive space to start room tracking.")
      Button("Enter immersive space") {
        Task {
          await openImmersiveSpace(id: ShowCase.roomTracking.immersiveSpaceId)
          roomState.isImmersive = true
        }
      }
    }
  }

  @MainActor
  var viewWhileImmersed: some View {
    VStack(spacing: 16) {
      Button {
        roomClassificationTrackingModel.roomParentEntity = roomState.roomParentEntity
        roomClassificationTrackingModel.saveModelEntity()
      } label: {
        Text("Export usdz File")
      }
      
      Button {
        previewURL = roomClassificationTrackingModel.selectedURL
      } label: {
        Text("Preview USDZ File")
      }
      .quickLookPreview($previewURL)

      Button("Leave immersive space") {
        Task {
          await dismissImmersiveSpace()
          roomState.isImmersive = false
        }
      }
    }
  }

  @MainActor
  var errorView: some View {
    var message: String
    switch roomState.errorState {
    case .noError: message = "" // Empty string, since the app only shows this view in case of an error.
    case .providerNotAuthorized: message = "The app hasn't authorized one or more data providers."
    case .providerNotSupported: message = "This device doesn't support one or more data providers."
    case .sessionError(let error): message = "Running the ARKitSession failed with an error: \(error)."
    }
    return Text(message)
  }
  
}

#Preview(windowStyle: .automatic) {
  RoomTrackingScreen()
}

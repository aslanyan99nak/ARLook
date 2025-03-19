//
//  ObjectScannerScreen.swift
//  ARLook
//
//  Created by Narek on 13.03.25.
//

import SwiftUI

enum ObjectScannerType: String, CaseIterable {

  case meshes
  case planeClassification
  case roomClassification

  var id: Int {
    switch self {
    case .meshes: 0
    case .planeClassification: 1
    case .roomClassification: 2
    }
  }

  var name: String {
    switch self {
    case .meshes: "Meshes"
    case .planeClassification: "PlaneClassification"
    case .roomClassification: "RoomClassification"
    }
  }

}

struct ObjectScannerScreen: View {

  @EnvironmentObject var model: WorldScaningTrackingModel
  @EnvironmentObject var planeClassificationModel: PlaneClassificationTrackingModel
  @EnvironmentObject var immseriveModel: ImmersiveModel
  @EnvironmentObject var roomClassificationTrackingModel: RoomClassificationTrackingModel
  @Environment(RoomState.self) var roomState
  @Environment(\.scenePhase) var scenePhase
  @Environment(\.openImmersiveSpace) var openImmersiveSpace
  @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
  @Environment(\.openWindow) var openWindow
  @Environment(\.dismissWindow) var dismissWindow

  @State private var previewURL: URL?
  @State private var selectedObjectScannerType = ObjectScannerType.meshes

  var body: some View {
    VStack(spacing: 40) {
      segmentedPickerView
        .padding(.top, 40)
      openDismissImmersiveSpaceButton
      exportButton
      previewButton
      if selectedObjectScannerType == .meshes {
        selectMaterialButton
      }
      if selectedObjectScannerType == .roomClassification {
        wallScannerView
      }
      Spacer()
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
          switch selectedObjectScannerType {
          case .meshes:
            await openImmersiveSpace(id: ShowCase.worldScaning.immersiveSpaceId)
            immseriveModel.immersiveSpaceId = ShowCase.worldScaning.immersiveSpaceId
          case .planeClassification:
            await openImmersiveSpace(id: ShowCase.planeClassification.immersiveSpaceId)
            immseriveModel.immersiveSpaceId = ShowCase.planeClassification.immersiveSpaceId
          case .roomClassification:
            await openImmersiveSpace(id: ShowCase.roomTracking.immersiveSpaceId)
            immseriveModel.immersiveSpaceId = ShowCase.roomTracking.immersiveSpaceId
          }
        }
      }
    } label: {
      Text(immseriveModel.immersiveSpaceId != nil ? "Dismiss Immersive Space" : "Show Immersive Space")
    }
  }
  
  private var exportButton: some View {
    Button {
      switch selectedObjectScannerType {
      case .meshes:
        model.saveModelEntity()
      case .planeClassification:
        planeClassificationModel.saveModelEntity()
      case .roomClassification:
        roomClassificationTrackingModel.roomParentEntity = roomState.roomParentEntity
        roomClassificationTrackingModel.saveModelEntity()
      }
    } label: {
      Text("Export usdz File")
    }
  }
  
  private var previewButton: some View {
    Button {
      switch selectedObjectScannerType {
      case .meshes:
        if let url = model.selectedURL {
          previewURL = url
        }
      case .planeClassification:
        if let url = planeClassificationModel.selectedURL {
          previewURL = url
        }
      case .roomClassification:
        previewURL = roomClassificationTrackingModel.selectedURL
      }
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

  var wallScannerView: some View {
    Group {
      if roomState.errorState != .noError {
        errorView
      }
    }
    .padding()
    .frame(width: 600)
    .onChange(of: scenePhase) {
      if scenePhase != .active && roomState.isImmersive {
        Task {
          await dismissImmersiveSpace()
          immseriveModel.immersiveSpaceId = nil
        }
      }
    }
    .onChange(of: roomState.errorState) {
      if roomState.errorState != .noError && roomState.isImmersive {
        Task {
          await dismissImmersiveSpace()
          immseriveModel.immersiveSpaceId = nil
        }
      }
    }
  }

  private var segmentedPickerView: some View {
    GeometryReader { geo in
      ObjectScannerTypeSegmentedControl(
        selection: $selectedObjectScannerType,
        size: .init(width: geo.size.width, height: 60)
      )
    }
    .frame(height: 60)
    .background(.ultraThickMaterial)
    .clipShape(Capsule())
    .padding(.horizontal, 40)
  }

  @MainActor
  var errorView: some View {
    var message: String
    switch roomState.errorState {
    case .noError: message = ""  // Empty string, since the app only shows this view in case of an error.
    case .providerNotAuthorized: message = "The app hasn't authorized one or more data providers."
    case .providerNotSupported: message = "This device doesn't support one or more data providers."
    case .sessionError(let error): message = "Running the ARKitSession failed with an error: \(error)."
    }
    return Text(message)
  }

}

#Preview(windowStyle: .automatic) {
  ObjectScannerScreen()
    .environment(RoomState())
    .environmentObject(WorldScaningTrackingModel())
    .environmentObject(PlaneClassificationTrackingModel())
    .environmentObject(ImmersiveModel())
    .environmentObject(RoomClassificationTrackingModel())
}

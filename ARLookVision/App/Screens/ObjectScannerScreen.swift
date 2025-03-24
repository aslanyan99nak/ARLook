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
  @EnvironmentObject var appModel: AppModel
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
      if appModel.immersiveSpaceId != nil {
        Task {
          await dismissImmersiveSpace()
          appModel.immersiveSpaceId = nil
        }
      }
    }
  }

  private var openDismissImmersiveSpaceButton: some View {
    Button {
      Task {
        if appModel.immersiveSpaceId != nil {
          await dismissImmersiveSpace()
          appModel.immersiveSpaceId = nil
        } else {
          switch selectedObjectScannerType {
          case .meshes:
            await openImmersiveSpace(id: ShowCase.worldScaning.immersiveSpaceId)
            appModel.immersiveSpaceId = ShowCase.worldScaning.immersiveSpaceId
          case .planeClassification:
            await openImmersiveSpace(id: ShowCase.planeClassification.immersiveSpaceId)
            appModel.immersiveSpaceId = ShowCase.planeClassification.immersiveSpaceId
          case .roomClassification:
            await openImmersiveSpace(id: ShowCase.roomTracking.immersiveSpaceId)
            appModel.immersiveSpaceId = ShowCase.roomTracking.immersiveSpaceId
          }
        }
      }
    } label: {
      Text(appModel.immersiveSpaceId != nil ? "Dismiss Immersive Space" : "Show Immersive Space")
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
      Text("Export File")
    }
  }

  private var previewButton: some View {
    Button {
      switch selectedObjectScannerType {
      case .meshes:
        guard let url = model.selectedURL else { return }
        previewURL = url
      case .planeClassification:
        guard let url = planeClassificationModel.selectedURL else { return }
        previewURL = url
      case .roomClassification:
        guard let url = roomClassificationTrackingModel.selectedURL else { return }
        previewURL = url
      }
    } label: {
      Text("View as a 3D")
    }
    .quickLookPreview($previewURL)
  }

  private var selectMaterialButton: some View {
    Button {
      if appModel.windowId.isNotNil {
        if appModel.windowId == WindowCase.changeMaterialColor.rawValue {
          dismissWindow(id: WindowCase.changeMaterialColor.rawValue)
          appModel.windowId = nil
        }
      } else {
        openWindow(id: WindowCase.changeMaterialColor.rawValue)
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
          appModel.immersiveSpaceId = nil
        }
      }
    }
    .onChange(of: roomState.errorState) {
      if roomState.errorState != .noError && roomState.isImmersive {
        Task {
          await dismissImmersiveSpace()
          appModel.immersiveSpaceId = nil
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
    case .noError: message = ""
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
    .environmentObject(AppModel())
    .environmentObject(RoomClassificationTrackingModel())
}

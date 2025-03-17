//
//  ARLookVisionApp.swift
//  ARLookVision
//
//  Created by Narek on 04.03.25.
//

import Photos
import RealityFoundation
import RealityKit
import SwiftUI

@main
@MainActor
struct ARLookVisionApp: App {

  @StateObject private var immersiveModel = ImmersiveModel()
  @StateObject private var worldScaningTrackingModel = WorldScaningTrackingModel()
  @StateObject private var planeClassificationModel = PlaneClassificationTrackingModel()
  @StateObject private var mainCameraTrackingModel = MainCameraTrackingModel()
  @StateObject private var roomClassificationTrackingModel = RoomClassificationTrackingModel()

  @State private var selectedColor: Color = .red
  @State private var opacity: Double = 0
  @State private var roomState = RoomState()

  var body: some SwiftUI.Scene {
    WindowGroup {
      OrnamentView()
        .environment(roomState)
        .environmentObject(immersiveModel)
        .environmentObject(worldScaningTrackingModel)
        .environmentObject(planeClassificationModel)
        .environmentObject(mainCameraTrackingModel)
        .environmentObject(roomClassificationTrackingModel)
    }

    WindowGroup(id: "ChangeMaterialColor") {
      VStack(spacing: 20) {
        SwiftUI.ColorPicker("ColorPicker", selection: $selectedColor)
          .onChange(of: selectedColor) { oldValue, newValue in
            let color = UIColor(newValue).withAlphaComponent(worldScaningTrackingModel.opacity)
            //            worldScaningTrackingModel.material = SimpleMaterial(color: color, isMetallic: false)
            worldScaningTrackingModel.material = UnlitMaterial(color: color)
          }

        Slider(value: $worldScaningTrackingModel.opacity, in: 0...1, step: 0.1)
          .onChange(of: worldScaningTrackingModel.opacity) { oldValue, newValue in
            let color = UIColor(selectedColor).withAlphaComponent(newValue)
            //            worldScaningTrackingModel.material = SimpleMaterial(
            //              color: UIColor(selectedColor).withAlphaComponent(newValue), isMetallic: false)
            worldScaningTrackingModel.material = UnlitMaterial(color: color)
          }

        Button {
          // TODO: - Change back

          //          worldScaningTrackingModel.saveModelEntity()
          planeClassificationModel.saveModelEntity()
        } label: {
          Text("Export usdz File")
        }
      }
      .padding(40)
    }

    //    WindowGroup {
    //      RoomTrackingScreen()
    //        .environment(roomState)
    //        .environmentObject(immersiveModel)
    //        .environmentObject(roomClassificationTrackingModel)
    //    }
    //    .defaultSize(CGSize(width: 800, height: 400))

    ImmersiveSpace(id: ShowCase.worldScaning.immersiveSpaceId) {
      WorldScaningImmersiveView()
        .environmentObject(worldScaningTrackingModel)
    }

    ImmersiveSpace(id: ShowCase.planeClassification.immersiveSpaceId) {
      PlaneClassificationImmersiveView()
        .environmentObject(planeClassificationModel)
    }

    ImmersiveSpace(id: ShowCase.mainCamera.immersiveSpaceId) {
      MainCameraView()
        .environmentObject(mainCameraTrackingModel)
    }

    ImmersiveSpace(id: ShowCase.qrScanner.immersiveSpaceId) {
      QRScannerScreen()
    }

    ImmersiveSpace(id: ShowCase.roomTracking.immersiveSpaceId) {
      WorldAndRoomView()
        .environment(roomState)
        .environmentObject(immersiveModel)
        .environmentObject(roomClassificationTrackingModel)
    }

  }

}

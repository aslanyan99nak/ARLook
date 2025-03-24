//
//  ARLookVisionApp.swift
//  ARLookVision
//
//  Created by Narek on 04.03.25.
//

import RealityFoundation
import RealityKit
import SwiftUI

@main
@MainActor
struct ARLookVisionApp: App {

  @StateObject private var appModel = AppModel()
  @StateObject private var worldScaningTrackingModel = WorldScaningTrackingModel()
  @StateObject private var planeClassificationModel = PlaneClassificationTrackingModel()
  @StateObject private var roomClassificationTrackingModel = RoomClassificationTrackingModel()
  @StateObject private var handTrackingViewModel = HandTrackingViewModel()

  @StateObject private var lookAroundViewModel = LookAroundImmersiveViewModel()

  @State private var selectedColor: Color = .red
  @State private var opacity: Double = 0
  @State private var roomState = RoomState()

  var body: some SwiftUI.Scene {
    WindowGroup {
      OrnamentView()
        .environment(roomState)
        .environmentObject(appModel)
        .environmentObject(worldScaningTrackingModel)
        .environmentObject(planeClassificationModel)
        .environmentObject(roomClassificationTrackingModel)
        .environmentObject(handTrackingViewModel)
        .environmentObject(lookAroundViewModel)
    }

    WindowGroup(id: WindowCase.changeMaterialColor.rawValue) {
      VStack(spacing: 20) {
        SwiftUI.ColorPicker("ColorPicker", selection: $selectedColor)
          .onChange(of: selectedColor) { oldValue, newValue in
            let color = UIColor(newValue).withAlphaComponent(worldScaningTrackingModel.opacity)
            worldScaningTrackingModel.material = SimpleMaterial(color: color, isMetallic: false)
            // worldScaningTrackingModel.material = UnlitMaterial(color: color)
          }

        Slider(value: $worldScaningTrackingModel.opacity, in: 0...1, step: 0.1)
          .onChange(of: worldScaningTrackingModel.opacity) { oldValue, newValue in
            let color = UIColor(selectedColor).withAlphaComponent(newValue)
            worldScaningTrackingModel.material = SimpleMaterial(color: color, isMetallic: false)
            // worldScaningTrackingModel.material = UnlitMaterial(color: color)
          }
      }
      .padding(40)
    }
    .defaultSize(width: 200, height: 200)
    
    WindowGroup(id: WindowCase.searchScreen.rawValue) {
      SearchScreen(isInImmersive: true)
        .environmentObject(lookAroundViewModel)
        .environmentObject(appModel)
    }

    ImmersiveSpace(id: ShowCase.worldScaning.immersiveSpaceId) {
      WorldScaningImmersiveView()
        .environmentObject(worldScaningTrackingModel)
    }

    ImmersiveSpace(id: ShowCase.planeClassification.immersiveSpaceId) {
      PlaneClassificationImmersiveView()
        .environmentObject(planeClassificationModel)
    }

    ImmersiveSpace(id: ShowCase.lookAround.immersiveSpaceId) {
      LookAroundImmersiveView()
        .environmentObject(lookAroundViewModel)
        .environmentObject(handTrackingViewModel)
        .environmentObject(appModel)
    }

    ImmersiveSpace(id: ShowCase.qrScanner.immersiveSpaceId) {
      QRScannerScreen()
    }

    ImmersiveSpace(id: ShowCase.roomTracking.immersiveSpaceId) {
      WorldAndRoomView()
        .environment(roomState)
        .environmentObject(appModel)
        .environmentObject(roomClassificationTrackingModel)
        .environmentObject(handTrackingViewModel)
    }

  }

}

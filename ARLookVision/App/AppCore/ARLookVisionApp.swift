//
//  ARLookVisionApp.swift
//  ARLookVision
//
//  Created by Narek on 04.03.25.
//

import RealityFoundation
import SwiftUI
import RealityKit

@main
struct ARLookVisionApp: App {

  @StateObject var immersiveModel: ImmersiveModel = .init()
  @StateObject var model = WorldScaningTrackingModel()

  @State private var selectedColor: Color = .red
  @State private var opacity: Double = 0

  var body: some SwiftUI.Scene {
    WindowGroup {
      OrnamentView()
        .environmentObject(immersiveModel)
        .environmentObject(model)
    }

    WindowGroup(id: "ChangeMaterialColor") {
      VStack(spacing: 20) {
        SwiftUI.ColorPicker("ColorPicker", selection: $selectedColor)
          .onChange(of: selectedColor) { oldValue, newValue in
            model.material = SimpleMaterial(color: UIColor(newValue).withAlphaComponent(model.opacity), isMetallic: false)
          }
        
        Slider(value: $model.opacity, in: 0...1, step: 0.1)
          .onChange(of: model.opacity) { oldValue, newValue in
            model.material = SimpleMaterial(color: UIColor(selectedColor).withAlphaComponent(newValue), isMetallic: false)
          }
        
        Button {
          model.saveModelEntity()
        } label: {
          Text("Export usdz File")
        }
      }
      .padding(40)
    }

    ImmersiveSpace(id: "WorldScaning") {
      WorldScaningImmersiveView()
        .environmentObject(model)
    }
  }

}

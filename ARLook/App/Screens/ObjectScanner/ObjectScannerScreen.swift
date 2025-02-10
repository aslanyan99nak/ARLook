//
//  ObjectScannerScreen.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import RealityKit
import SwiftUI

struct ObjectScannerScreen: View {

  @StateObject var appModel: AppDataModel = AppDataModel.instance
  @Environment(\.colorScheme) private var colorScheme
  @State private var showReconstructionView: Bool = false
  @State private var showErrorAlert: Bool = false
  
  private var tintColor: Color { colorScheme == .light ? .black : .white }

  private var showProgressView: Bool {
    appModel.state == .completed || appModel.state == .restart || appModel.state == .ready
  }

  var body: some View {
    VStack {
      if appModel.state == .capturing {
        if let session = appModel.objectCaptureSession {
          CapturePrimaryView(session: session)
        }
      } else if showProgressView {
        CircularProgressView(tintColor: tintColor)
      }
    }
    .onChange(of: appModel.state) { _, newState in
      appStateChanged(newState)
    }
    .sheet(isPresented: $showReconstructionView) {
      if let folderManager = appModel.scanFolderManager {
        ReconstructionPrimaryView(
          outputFile: folderManager.modelsFolder.appendingPathComponent("model-mobile.usdz")
        )
      }
    }
    .alert(
      "Failed:  " + (appModel.error.isNotNil ? "\(String(describing: appModel.error!))" : ""),
      isPresented: $showErrorAlert
    ) {
      alertOkButton
    }
    .environmentObject(appModel)
  }

  private func appStateChanged(_ newState: AppDataModel.ModelState) {
    if newState == .failed {
      showErrorAlert = true
      showReconstructionView = false
    } else {
      showErrorAlert = false
      showReconstructionView = newState == .reconstructing || newState == .viewing
    }
  }
  
  private var alertOkButton: some View {
    Button {
      print("Calling restart...")
      appModel.state = .restart
    } label: {
      Text("OK")
    }
  }

}

#Preview {
  ObjectScannerScreen()
}

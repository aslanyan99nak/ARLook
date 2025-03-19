//
//  MainScreen.swift
//  ARLook
//
//  Created by Narek on 05.03.25.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct MainScreen: View {

  @StateObject private var viewModel = MainViewModel()

  var body: some View {
    NavigationSplitView {
      SideBarView(
        selectedItem: $viewModel.selectedItem,
        sideMenuItems: $viewModel.sideMenuItems
      )
      .toolbar {
        ToolbarItem(placement: .principal) {
          HStack(spacing: 16) {
            Spacer()
            Image(.appIcon)
              .resizable()
              .frame(width: 40, height: 40)
            Text("ARLook")
              .font(.title)
              .fontWeight(.bold)
            Spacer()
          }
        }
      }
      .onChange(of: viewModel.selectedURL) { oldValue, newValue in
        if newValue.isNil {
          guard let index = viewModel.sideMenuItems.firstIndex(of: .view3DMode) else { return }
          viewModel.sideMenuItems.remove(at: index)
        } else {
          if oldValue != newValue {
            guard !viewModel.sideMenuItems.contains(.view3DMode),
              let index = viewModel.sideMenuItems.firstIndex(of: .file)
            else { return }
            viewModel.sideMenuItems.insert(.view3DMode, at: index + 1)
          }
        }
      }
    } detail: {
      selectedDetailView
    }
  }

  @ViewBuilder
  private var selectedDetailView: some View {
    if let selectedItem = viewModel.selectedItem {
      switch selectedItem {
      case .objectScanner: ObjectScannerScreen()
      case .upload: UploadModelScreen()
//      case .qrCodeScanner: QRScannerView()
      case .importQR:
        QRImageScannerView { code in
          viewModel.scannedCode = code
        }
      case .file:
        FileScreen { url in
          viewModel.selectedURL = url
        }
      case .lookAround: LookAroundScreen()
      case .view3DMode:
        View3DScreen(previewURL: $viewModel.previewURL) {
          viewModel.previewURL = viewModel.selectedURL
        }
      }
    } else {
      ContentUnavailableView("Select an element from the sidebar", systemImage: "doc.text.image.fill")
    }
  }

}

#Preview(windowStyle: .automatic) {
  MainScreen()
}

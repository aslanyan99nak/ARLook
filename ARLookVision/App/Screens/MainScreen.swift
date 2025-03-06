//
//  MainScreen.swift
//  ARLook
//
//  Created by Narek on 05.03.25.
//

import RealityKit
import RealityKitContent
import SwiftUI
import VisionKit

struct MainScreen: View {
  
  @State private var selectedItem: SideMenuItem?

  var body: some View {
    NavigationSplitView {
      SideBarView(selectedItem: $selectedItem)
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
    } detail: {
      selectedDetailView
    }
  }
  
  @ViewBuilder
  private var selectedDetailView: some View {
    if let selectedItem {
      switch selectedItem {
      case .upload: UploadModelScreen2()
      case .qrCodeScanner: QRScannerView()
      case .importQR: QRImageScannerView { code in
//          viewModel.scannedCode = code
//          if !navigationPath.isEmpty {
//            navigationPath.removeLast(navigationPath.count)
//          }
      }
      case .file:
        DocumentPicker { url in
//            viewModel.savedFilePath = nil
//            viewModel.selectedURL = url
        }
      case .lookAround: Text(selectedItem.description)
      }
    } else {
      ContentUnavailableView("Select an element from the sidebar", systemImage: "doc.text.image.fill")
    }
  }
  
}

#Preview(windowStyle: .automatic) {
  MainScreen()
}

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
          navigationBar
        }
      }
      .onChange(of: viewModel.selectedURL) { oldValue, newValue in
        selectedURLChanged(oldValue, newValue)
      }
      .onChange(of: viewModel.scannedCode) { oldValue, newValue in
        if oldValue != newValue {
          viewModel.setupDocument()
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
      case .importQR: importQRScreen
      case .file: fileScreen
      case .lookAround: LookAroundScreen()
      case .view3DMode: view3DScreen
      }
    } else {
      SidebarEmptyView()
    }
  }
  
  private var view3DScreen: some View {
    View3DScreen(previewURL: $viewModel.previewURL) {
      viewModel.previewURL = viewModel.selectedURL
    }
  }
  
  private var fileScreen: some View {
    FileScreen { url in
      viewModel.selectedURL = url
    }
  }
  
  private var importQRScreen: some View {
    QRImageScannerView { code in
      viewModel.scannedCode = code
      guard let code = viewModel.scannedCode?.convertedFileNameFromURLString, !code.isEmpty else { return }
      viewModel.modelManager.checkFileExists(fileName: code) { isExists, url in
        if let url, isExists {
          viewModel.selectedURL = url
        }
      }
    }
  }
  
  private var navigationBar: some View {
    HStack(spacing: 0) {
      Spacer()
      Image(.arLookVision)
      Spacer()
    }
  }
  
  private func selectedURLChanged(_ oldValue: URL?, _ newValue: URL?) {
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

}

#Preview(windowStyle: .automatic) {
  MainScreen()
}

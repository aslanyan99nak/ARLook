//
//  MainScreen.swift
//  ARLook
//
//  Created by Narek Aslanyan on 03.02.25.
//

import QRCode
import QuickLook
import SwiftUI

extension MainScreen {

  enum Destination: Hashable {

    case modelScanner
    case importQR
    case look
    case uploadModel

  }

}

struct MainScreen: View {

  @StateObject private var viewModel = MainViewModel()
  @EnvironmentObject private var popupVM: PopupViewModel
  @AppStorage(CustomColorScheme.defaultKey) var colorScheme = CustomColorScheme.defaultValue
  @State private var navigationPath = NavigationPath()

  var body: some View {
    NavigationStack(path: $navigationPath) {
      contentView
        .onLoad {
          Task {
            await viewModel.getModels()
          }
        }
        .onOpenURL { url in
          print("Opened from: \(url.absoluteString)")
          guard let code = url.absoluteString.convertedFileNameFromURLString, !code.isEmpty else { return }
          viewModel.modelManager.checkFileExists(fileName: code) { isExists, url in
            if let url, isExists {
              viewModel.fileURL = url
              viewModel.scannedCode = code
            }
          }
        }
        .navigationDestination(for: Destination.self) { destination in
          switch destination {
          case .modelScanner: ObjectScannerScreen()
          case .importQR:
            QRImageScannerView { code in
              viewModel.scannedCode = code
              if !navigationPath.isEmpty {
                navigationPath.removeLast(navigationPath.count)
              }
            }
          case .look: LookScreen()
          case .uploadModel: UploadModelScreen()
          }
        }
        .ignoresSafeArea()
        .navigationTitle(LocString.arLook)
    }
    .sheet(isPresented: $viewModel.isShowPicker) {
      DocumentPicker { url in
        viewModel.savedFilePath = nil
        viewModel.selectedURL = url
      }
    }
  }

  private var contentView: some View {
    ZStack {
      ScrollView(showsIndicators: false) {
        VStack(spacing: 10) {
          // fileInfoDebugView
          modelScannerButton
          qrCodeView
          uploadButton
          if viewModel.scannedCode.isNotNil || viewModel.selectedURL.isNotNil {
            showModelButton
          }
          scanButton
          importQRButton
          chooseButton
          lookButton
        }
        .padding(.top, 150)
        .padding(.bottom, 150)
      }

      if viewModel.isShowScanner {
        scanner
          .toolbar(.hidden, for: .navigationBar)
          .toolbar(.hidden, for: .tabBar)
          .transition(.scale)
      }
    }
  }

  private var uploadButton: some View {
    Button {
      navigationPath.append(Destination.uploadModel)
    } label: {
      ItemRow(
        image: viewModel.savedFilePath.isNil
          ? Image(systemName: Image.upload) : Image(systemName: Image.checkMarkCircle),
        title: viewModel.savedFilePath.isNil
          ? LocString.upload : LocString.uploaded,
        description: viewModel.savedFilePath.isNil
          ? LocString.uploadDescription : LocString.uploadedDescription
      )
    }
    .padding(.horizontal, 16)
  }

  private var scanner: some View {
    QRCodeScanner(
      fileURL: $viewModel.fileURL,
      isShowScanner: $viewModel.isShowScanner
    ) { code in
      viewModel.scannedCode = code
    }
    .zIndex(1)
  }

  private var scanButton: some View {
    Button {
      withAnimation(.easeInOut(duration: 0.3)) {
        viewModel.isShowScanner = true
      }
    } label: {
      ItemRow(
        image: Image(systemName: Image.qrCodeScanner),
        title: LocString.qrCodeScannerTitle,
        description: LocString.qrCodeScannerDescription
      )
    }
    .padding(.horizontal, 16)
  }

  private var importQRButton: some View {
    Button {
      navigationPath.append(Destination.importQR)
    } label: {
      ItemRow(
        image: Image(systemName: Image.qrCode),
        title: LocString.importQRTitle,
        description: LocString.importQRDescription
      )
    }
    .padding(.horizontal, 16)
  }

  private var showModelButton: some View {
    Button {
      if viewModel.selectedURL.isNotNil {
        viewModel.previewURL = viewModel.selectedURL
      } else if viewModel.fileURL.isNotNil {
        viewModel.previewURL = viewModel.fileURL
      }
    } label: {
      ItemRow(
        image: Image(systemName: Image.arkit),
        title: LocString.view3DMode,
        description: "Experience a detailed 3D view with a single tap."
      )
    }
    .quickLookPreview($viewModel.previewURL)
    .padding(.horizontal, 16)
  }

  private var chooseButton: some View {
    Button {
      viewModel.isShowPicker = true
    } label: {
      ItemRow(
        image: Image(.openFile),
        title: LocString.fileManagmentTitle,
        description: LocString.fileManagmentDescription
      )
    }
    .padding(.horizontal, 16)
  }

  private var lookButton: some View {
    Button {
      navigationPath.append(Destination.look)
    } label: {
      ItemRow(
        image: Image(systemName: "eye"),
        title: "Look around",
        description: "Look around description"
      )
    }
    .padding(.horizontal, 16)
  }

  private var qrCodeView: some View {
    VStack(spacing: 0) {
      if viewModel.image.isNotNil {
        ShareMenuItemsView(
          isDefaultImage: .constant(false),
          scannedText: $viewModel.scannedCode,
          selectedImage: $viewModel.image
        )
      }
    }
    .padding(.horizontal, 16)
    .onChange(of: viewModel.scannedCode) { oldValue, newValue in
      if oldValue != newValue {
        viewModel.setupDocument()
      }
    }
  }

  private var modelScannerButton: some View {
    Button {
      if UIDevice.hasLiDAR {
        let screen = Destination.modelScanner
        navigationPath.append(screen)
      } else {
        withAnimation(.easeInOut(duration: 0.5)) {
          popupVM.isShowPopup = true
          popupVM.popupContent = AnyView(popupView)
        }
      }
    } label: {
      Image(.capture3D)
        .resizable()
        .frame(width: 100, height: 100)
    }
    .padding(.top, 16)
  }

  private var popupView: some View {
    PopupView {
      withAnimation(.easeInOut(duration: 0.5)) {
        popupVM.isShowPopup = false
        popupVM.popupContent = AnyView(EmptyView())
      }
    }
  }

}

#Preview {
  MainScreen()
}

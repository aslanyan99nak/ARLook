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
    case uploadModel(url: URL?)
    case qrScanner

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
          case let .uploadModel(url): UploadModelScreen(url: url)
          case .qrScanner:
            scanner
              .ignoresSafeArea()
              .toolbar(.hidden, for: .navigationBar)
              .onAppear {
                withAnimation(.easeInOut(duration: 0.1)) {
                  popupVM.isShowTabBar = false
                }
              }
              .onDisappear {
                withAnimation(.easeInOut(duration: 0.1)) {
                  popupVM.isShowTabBar = true
                }
              }
          }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .principal) {
            Image(.arLook)
          }
        }
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
        VStack(spacing: 0) {
          // fileInfoDebugView
          Image(.mainScreenBar)
            .resizable()
          modelScannerButton
          qrCodeView
          uploadButton
            .padding(.vertical, 10)
          if viewModel.scannedCode.isNotNil || viewModel.selectedURL.isNotNil {
            showModelButton
              .padding(.bottom, 10)
          }
          scanButton
          importQRButton
            .padding(.top, 10)
          chooseButton
            .padding(.vertical, 10)
          lookButton
          Spacer()
        }
        .padding(.bottom, 150)
      }

//      if viewModel.isShowScanner {
//        scanner
//          .ignoresSafeArea()
//          .toolbar(.hidden, for: .navigationBar)
////          .onAppear {
////            withAnimation {
////              popupVM.isShowTabBar = false
////            }
////          }
//          .onDisappear {
//            withAnimation {
//              popupVM.isShowTabBar = true
//            }
//          }
//          .transition(.scale)
//      }
    }
  }

  private var uploadButton: some View {
    Button {
      navigationPath.append(Destination.uploadModel(url: nil))
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
      navigationPath.append(Destination.qrScanner)
//      withAnimation(completionCriteria: .logicallyComplete) {
//        popupVM.isShowTabBar = false
//      } completion: {
//        withAnimation(.easeInOut(duration: 1)) {
//          viewModel.isShowScanner = true
//        }
//      }
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
        description: LocString.viewModelDescription
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
      withAnimation(.easeInOut(duration: 0.1)) {
        popupVM.isShowTabBar = false
      }
      navigationPath.append(Destination.look)
    } label: {
      ItemRow(
        image: Image(systemName: Image.eye),
        title: LocString.lookAroundTitle,
        description: LocString.lookAroundDescription
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
        .padding(.bottom, 10)
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
      Image(.capture3DButton)
    }
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

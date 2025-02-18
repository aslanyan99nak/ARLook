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
        .navigationDestination(for: Destination.self) { destination in
          if case .modelScanner = destination {
            ObjectScannerScreen()
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
          chooseButton
        }
        .padding(.top, 150)
        .padding(.bottom, 150)
      }

      if viewModel.isShowScanner {
        scanner
          .toolbar(.hidden, for: .navigationBar)
          .toolbar(.hidden, for: .tabBar)
      }
    }
  }

  @ViewBuilder
  private var uploadButton: some View {
    if let selectedURL = viewModel.selectedURL {
      Button {
        // Saving
        if viewModel.savedFilePath.isNil {
          let number = Int.random(in: 1...20)
          viewModel.modelManager.saveFile(from: selectedURL, to: "model\(number).usdz") {
            success, savedURL in
            if success {
              DispatchQueue.main.async {
                viewModel.savedFilePath = savedURL?.path
              }
            }
          }
        }
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
      .disabled(viewModel.savedFilePath.isNotNil)
    }
  }

  private var scanner: some View {
    QRCodeScanner(
      fileURL: $viewModel.fileURL,
      isShowScanner: $viewModel.isShowScanner,
      scannedCode: $viewModel.scannedCode,
      scale: $viewModel.scale
    )
  }

  private var scanButton: some View {
    Button {
      viewModel.isShowScanner = true
      withAnimation(.easeInOut) {
        viewModel.scale = 1
      }
    } label: {
      ItemRow(
        image: Image(systemName: Image.qrCode),
        title: LocString.qrCodeScannerTitle,
        description: LocString.qrCodeScannerDescription
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
      Show3DCardView()
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

  private var qrCodeView: some View {
    VStack(spacing: 0) {
      if let image = viewModel.image {
        Menu {
          shareButton
        } label: {
          Image(uiImage: UIImage(cgImage: image))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .frame(width: 200, height: 200)
            .shadow(radius: 10)
            .padding(.top, 16)
        }
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
        // Show popup
        print("Show Popup")
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

  private var shareButton: some View {
    Button {
      // Share Action
      if let url = URL(string: "https://example.com/\(viewModel.scannedCode ?? "")") {
        viewModel.shareSheet(url: url)
      }
    } label: {
      HStack(spacing: 4) {
        Text(LocString.share)
          .dynamicFont()

        Image(systemName: Image.download)
          .resizable()
          .frame(width: 16, height: 16)
      }
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

//  private var fileInfoDebugView: some View {
//    VStack(spacing: 10) {
//      Text("Scanned Code \(viewModel.scannedCode ?? "empty")")
//      if let path = viewModel.savedFilePath {
//        Text("Saved File Path:\n\(path)")
//          .padding()
//          .multilineTextAlignment(.center)
//      }
//    }
//  }

}

#Preview {
  MainScreen()
}

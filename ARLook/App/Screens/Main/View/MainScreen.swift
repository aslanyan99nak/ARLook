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

  @Environment(\.colorScheme) var colorScheme
  @StateObject private var viewModel = MainViewModel()
  @State private var navigationPath = NavigationPath()

  private var isDarkMode: Bool {
    colorScheme == .dark
  }

  var body: some View {
    NavigationStack(path: $navigationPath) {
      contentView
        .navigationDestination(for: Destination.self) { destination in
          if case .modelScanner = destination {
            ObjectScannerScreen()
          }
        }
        .ignoresSafeArea()
        .navigationTitle(String.LocString.arLook)
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
      } else if viewModel.isShowPopup {
        Rectangle()
          .background(Material.regular)
          .ignoresSafeArea()

        VStack(spacing: 20) {
          Text(String.LocString.canNotScanModel)
            .foregroundStyle(isDarkMode ? .white : .black)

          Button {
            withAnimation {
              viewModel.isShowPopup = false
            }
          } label: {
            Text(String.LocString.ok)
              .foregroundStyle(.white)
              .padding(.vertical, 8)
              .frame(minWidth: 100, idealWidth: 100, maxWidth: 140)
              .background(Color.purple)
              .clipShape(Capsule())
          }
        }
        .padding()
        .background(.regularMaterial)
        .background(isDarkMode ? Color.gray.opacity(0.15) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(radius: 10)
        .padding(.horizontal, 16)
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
            ? Image(systemName: "square.and.arrow.down") : Image(systemName: "checkmark.seal"),
          title: viewModel.savedFilePath.isNil
            ? String.LocString.upload : String.LocString.uploaded,
          description: viewModel.savedFilePath.isNil
            ? String.LocString.uploadDescription : String.LocString.uploadedDescription
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
        image: Image(systemName: "qrcode"),
        title: String.LocString.qrCodeScannerTitle,
        description: String.LocString.qrCodeScannerDescription
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
        title: String.LocString.fileManagmentTitle,
        description: String.LocString.fileManagmentDescription
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
        withAnimation {
          viewModel.isShowPopup = true
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
        Text(String.LocString.share)

        Image(systemName: "square.and.arrow.up")
          .resizable()
          .frame(width: 16, height: 16)
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

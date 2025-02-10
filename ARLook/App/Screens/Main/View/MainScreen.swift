//
//  MainScreen.swift
//  ARLook
//
//  Created by Narek Aslanyan on 03.02.25.
//

import QRCode
import QuickLook
import SwiftUI

struct MainScreen: View {

  @StateObject private var viewModel = MainViewModel()

  var body: some View {
    NavigationStack {
      contentView
        .ignoresSafeArea()
        .navigationTitle("AR LOOK")
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
      ScrollView {
        VStack(spacing: 10) {
          // scannedCodeView
          if let path = viewModel.savedFilePath {
            Text("Saved File Path:\n\(path)")
              .padding()
              .multilineTextAlignment(.center)
          }
          uploadButton
          if viewModel.scannedCode.isNotNil || viewModel.selectedURL.isNotNil {
            showModelButton
          }
          qrCodeView
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
            ? Image(systemName: "square.and.arrow.down") : Image(systemName: "checkmark.seal"),
          title: viewModel.savedFilePath.isNil ? "Upload" : "Uploaded",
          description: viewModel.savedFilePath.isNil
            ? "Upload your 3D model for using by QR" : "You have succesfully uploaded your 3D model"
        )
      }
      .padding(.horizontal, 16)
      .disabled(viewModel.savedFilePath.isNotNil)
    }
  }

  private var scannedCodeView: some View {
    Text("Scanned Code \(viewModel.scannedCode ?? "empty")")
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
        title: "QR code Scanner",
        description: "Scan QR codes with ease"
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
  }

  private var chooseButton: some View {
    Button {
      viewModel.isShowPicker = true
    } label: {
      ItemRow(
        image: Image(.openFile),
        title: "File Management",
        description: "Open and organize your files"
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
            .frame(width: 200, height: 200)
            .padding(.top, 16)
        }
      }
//      } else {
//        Image(.qrEmpty)
        Image(.capture3D)
          .resizable()
          .frame(width: 200, height: 200)
          .padding(.top, 16)
//      }
    }
    .padding(.horizontal, 16)
    .onChange(of: viewModel.scannedCode) { oldValue, newValue in
      if oldValue != newValue {
        viewModel.setupDocument()
      }
    }
  }

  private var shareButton: some View {
    Button {
      // Share Action
      if let url = URL(string: "https://example.com/\(viewModel.scannedCode ?? "")") {
        viewModel.shareSheet(url: url)
      }
    } label: {
      HStack(spacing: 4) {
        Text("Share")

        Image(systemName: "square.and.arrow.up")
          .resizable()
          .frame(width: 16, height: 16)
      }
    }
  }

}

#Preview {
  MainScreen()
}

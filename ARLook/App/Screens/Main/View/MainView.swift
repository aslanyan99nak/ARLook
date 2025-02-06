//
//  MainView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 03.02.25.
//

import QRCode
import SwiftUI

struct MainView: View {

  @StateObject private var viewModel = MainViewModel()

  var body: some View {
    NavigationStack {
      ZStack {
        ScrollView {
          VStack(spacing: 10) {
            // scannedCodeView

            if let path = viewModel.savedFilePath {
              Text("Saved File Path:\n\(path)")
                .padding()
                .multilineTextAlignment(.center)
            }

            if let selectedURL = viewModel.selectedURL {
              Button {
                // Saving
                if viewModel.savedFilePath == nil {
                  let number = Int.random(in: 1...20)
                  viewModel.modelManager.saveFile(from: selectedURL, to: "model\(number).usdz") { success, savedURL in
                    if success {
                      DispatchQueue.main.async {
                        viewModel.savedFilePath = savedURL?.path
                      }
                    }
                  }
                }
              } label: {
                ItemRow(
                  image: viewModel.savedFilePath == nil ? Image(systemName: "square.and.arrow.down") : Image(systemName: "checkmark.seal"),
                  title: viewModel.savedFilePath == nil ? "Upload" : "Uploaded",
                  description: viewModel.savedFilePath == nil ? "Upload your 3D model for using by QR" : "You have succesfully uploaded your 3D model"
                )
              }
              .padding(.horizontal, 16)
              .disabled(viewModel.savedFilePath != nil)
            }

            if viewModel.scannedCode != nil || viewModel.selectedURL != nil {
              showModelButton
            }
            qrCodeView
            scanButton
            chooseButton

            fileNames
          }
          .padding(.top, 150)
        }

        if viewModel.isShowScanner {
          scanner
            .navigationBarHidden(true)
//            .toolbarVisibility(.hidden, for: .navigationBar)
        }
      }
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
      if viewModel.selectedURL != nil {
        viewModel.previewURL = viewModel.selectedURL
      } else if viewModel.fileURL != nil {
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
        } label: {
          Image(uiImage: UIImage(cgImage: image))
            .resizable()
            .frame(width: 200, height: 200)
            .padding(.top, 16)
        }

      } else {
        Image(.qrEmpty)
          .resizable()
          .frame(width: 200, height: 200)
          .padding(.top, 16)
      }
    }
    .padding(.horizontal, 16)
    .onChange(of: viewModel.scannedCode) { oldValue, newValue in
      if oldValue != newValue {
        viewModel.setupDocument()
      }
    }
  }

  private var fileNames: some View {
    VStack(alignment: .leading, spacing: 10) {
      let files = viewModel.modelManager.loadFiles()
      if !files.isEmpty {
        HStack(spacing: 0) {
          Text("Existing Models")
            .foregroundStyle(.black)
            .font(.title)
            .fontWeight(.bold)
            .padding()
          
          Spacer()
        }
      }
      
      ForEach(files, id: \.self) { file in
        HStack(spacing: 0) {
          Text(file)
            .foregroundStyle(.black)
            .padding()
            .background(Color.gray.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 8))
          
          Spacer()
        }
        .padding(.horizontal, 16)
      }
    }
    .padding(.bottom, 40)
  }
  
}

#Preview {
  MainView()
}

//
//  QRCodeScanner.swift
//  ARLook
//
//  Created by Narek Aslanyan on 03.02.25.
//

import CodeScanner
import SwiftUI

struct QRCodeScanner: View {

  @State private var isShow: Bool = false
  @State private var scannedCode: String?
  @Binding var fileURL: URL?
  @Binding var isShowScanner: Bool
  
  private let modelManager = ModelManager.shared
  var scannedCodeCompletion: (String?) -> Void

  var body: some View {
    contentView
  }
  
  private var contentView: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      scannerView
      overlayViews
    }
  }
  
  private var overlayViews: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Spacer()
        closeButton
      }
      .padding(.horizontal, 16)
      .padding(.top, 50)

      Spacer()

      if scannedCode.isNotNil && fileURL.isNil {
        fileNotFoundButton
        Spacer()
      }
    }
  }
  
  private var scannerView: some View {
    CodeScannerView(
      codeTypes: [.qr],
      scanMode: .continuous,
      showViewfinder: true,
      shouldVibrateOnSuccess: true
    ) { response in
      if case let .success(result) = response {
        guard let code = result.string.convertedFileNameFromURLString, !code.isEmpty else { return }
        scannedCode = code
        modelManager.checkFileExists(fileName: code) { isExists, url in
          if let url, isExists {
            fileURL = url
            withAnimation(.easeInOut(duration: 0.3)) {
              isShowScanner = false
            } completion: {
              scannedCodeCompletion(scannedCode)
            }
          }
        }
      }
    }
  }
  
  private var fileNotFoundButton: some View {
    Button {
      scannedCode = nil
    } label: {
      Text(LocString.fileNotFound)
        .dynamicFont()
        .foregroundStyle(.white)
        .padding()
        .background(Color.purple)
        .clipShape(Capsule())
    }
    .padding(.bottom, 60)
  }

  private var closeButton: some View {
    Button {
      withAnimation(.easeInOut(duration: 0.3)) {
        isShowScanner = false
      } completion: {
        if scannedCode.isNotNil && fileURL.isNil {
          scannedCode = nil
          scannedCodeCompletion(nil)
        }
      }
    } label: {
      Image(systemName: Image.xMark)
        .renderingMode(.template)
        .resizable()
        .frame(width: 16, height: 16)
        .padding()
        .background(.regularMaterial)
        .clipShape(Circle())
    }
  }

}

#Preview {
  QRCodeScanner(
    fileURL: .constant(nil),
    isShowScanner: .constant(false),
    scannedCodeCompletion: { _ in }
  )
}

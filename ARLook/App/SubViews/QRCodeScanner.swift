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
  @Binding var scale: CGFloat
  
  private let modelManager = ModelManager.shared
  var scannedCodeCompletion: (String?) -> Void

  var body: some View {
    contentView
  }
  
  private var contentView: some View {
    ZStack {
      scannerView
      overlayViews
    }
    .scaleEffect(scale)
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
            withAnimation(.easeInOut) {
              scale = 0
            } completion: {
              isShowScanner = false
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
      withAnimation(.easeInOut) {
        scale = 0
      } completion: {
        if scannedCode.isNotNil && fileURL.isNil {
          scannedCode = nil
          scannedCodeCompletion(nil)
        }
        isShowScanner = false
      }
    } label: {
      Image(systemName: Image.xMarkCircle)
        .renderingMode(.template)
        .resizable()
        .frame(width: 40, height: 40)
        .foregroundStyle(.white)
        .background(.regularMaterial)
        .clipShape(Circle())
    }
  }

}

#Preview {
  QRCodeScanner(
    fileURL: .constant(nil),
    isShowScanner: .constant(false),
    scale: .constant(1),
    scannedCodeCompletion: { _ in }
  )
}

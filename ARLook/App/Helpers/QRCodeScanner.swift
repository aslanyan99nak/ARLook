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
  @Binding var fileURL: URL?
  @Binding var isShowScanner: Bool
  @Binding var scannedCode: String?
  @Binding var scale: CGFloat

  var body: some View {
    CodeScannerView(
      codeTypes: [.qr],
      scanMode: .continuous,
      showViewfinder: true,
      shouldVibrateOnSuccess: true
    ) { response in
      if case let .success(result) = response {
        guard let code = getFileName(from: result.string), !code.isEmpty else { return }
        scannedCode = code
        checkFileExists(fileName: code) { isExists, url in
          if let url, isExists {
            fileURL = url
            withAnimation(.easeInOut) {
              scale = 0
            } completion: {
              isShowScanner = false
            }
          }
        }
      }
    }
    .overlay {
      VStack(spacing: 0) {
        HStack(spacing: 0) {
          Spacer()
          closeButton
        }
        .padding(.horizontal, 16)
        .padding(.top, 40)

        Spacer()

        if scannedCode != nil && fileURL == nil {
          Text("File not found")
            .foregroundStyle(.white)
            .padding()
            .background(Color.purple)
            .clipShape(Capsule())
            .padding(.bottom, 60)
            .onTapGesture {
              scannedCode = nil
            }

          Spacer()
        }

      }
    }
    .scaleEffect(scale)
  }

  var closeButton: some View {
    Button {
      withAnimation(.easeInOut) {
        scale = 0
      } completion: {
        isShowScanner = false
      }
    } label: {
      Image(systemName: "xmark")
        .resizable()
        .frame(width: 20, height: 20)
        .foregroundStyle(.black)
        .padding(8)
        .background(.white)
        .clipShape(Circle())
    }
  }

  func checkFileExists(fileName: String, completion: (Bool, URL?) -> Void) {
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsURL.appendingPathComponent(fileName)
    let isExists = fileManager.fileExists(atPath: fileURL.path)
    isExists && !fileName.isEmpty ? completion(isExists, fileURL) : completion(isExists, nil)
  }

//  func getFileName(from urlString: String) -> String? {
//    urlString.components(separatedBy: "/").last
//  }

}

func getFileName(from urlString: String) -> String? {
  urlString.components(separatedBy: "/").last
}

#Preview {
  QRCodeScanner(
    fileURL: .constant(nil),
    isShowScanner: .constant(false),
    scannedCode: .constant(""),
    scale: .constant(0)
  )
}

//
//  QRScannerView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 31.01.25.
//

import Combine
import QRCode
import SwiftUI

struct QRImageScannerView: View {

  @State private var isDefaultImage = true
  @State private var scannedText: String?
  @State private var selectedImage: UIImage? = UIImage(named: Image.qrEmpty)
  @State private var isShowPicker = false
  var scannedImageCompletion: (String?) -> Void

  var body: some View {
    ZStack {
      VStack(spacing: 0) {
        infoView
        menuItemsView
        scannedTextView
        Spacer()
      }
    }
    .sheet(isPresented: $isShowPicker) {
      ImagePicker(
        image: $selectedImage,
        isShowPicker: $isShowPicker
      )
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        if let scannedText, !scannedText.isEmpty {
          Button {
            scannedImageCompletion(scannedText)
          } label: {
            Text(LocString.done)
          }
        }
      }
    }
    .onChange(of: selectedImage) { oldValue, newValue in
      isDefaultImage = false
      let image = newValue?.cgImage
      guard let messages = image?.detectQRCodeStrings() else { return }
      scannedText = messages.count > 0 ? messages.first : nil
    }
  }

  private var infoView: some View {
    Text(LocString.shareDescription)
      .multilineTextAlignment(.center)
      .dynamicFont(size: 20, weight: .medium)
      .padding(.top, 20)
      .padding(.horizontal, 20)
  }

  @ViewBuilder
  private var scannedTextView: some View {
    if let scannedText {
      Text(scannedText)
        .dynamicFont(size: 18)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
  }

  @ViewBuilder
  private var menuItemsView: some View {
    if selectedImage.isNotNil {
      ShareMenuItemsView(
        isDefaultImage: $isDefaultImage,
        scannedText: $scannedText,
        selectedImage: $selectedImage
      ) {
        isShowPicker = true
      }
      .padding(.top, 20)
    }
  }

}

#Preview {
  QRImageScannerView { _ in }
}

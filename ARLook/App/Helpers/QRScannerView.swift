//
//  QRScannerView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 31.01.25.
//

import QRCode
import SwiftUI

struct QRScannerView: View {

  @State private var scannedText: String = "Scan a QR Code"

  var body: some View {
    VStack(spacing: 0) {
      Spacer()
      
      Text(scannedText)
        .foregroundStyle(Color.black)
        .font(.title)
        .padding()
        .background(Color.white)
      
      Image(.qrCode)
        .resizable()
        .frame(width: 300, height: 300)
        .padding(.top, 16)
      
      Spacer()
    }
    .onAppear {
      let image = UIImage(named: "QRCode")?.cgImage
      guard let messages = image?.detectQRCodeStrings() else { return }
      scannedText = messages.count > 0 ? messages.first ?? "Scan a QR Code" : ""
    }
  }
  
}

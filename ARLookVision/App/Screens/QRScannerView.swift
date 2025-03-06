//
//  QRScannerView.swift
//  ARLook
//
//  Created by Narek on 05.03.25.
//

import SwiftUI
import VisionKit

struct QRScannerView: View {
  
  @State private var scannerPresented = false
  @State private var scannedCode: String?

  var body: some View {
    VStack {
      if let code = scannedCode {
        Text("Scanned QR Code: \(code)")
          .padding()
      }
      Button("Scan QR Code") {
        scannerPresented = true
      }
      .padding()
    }
    .sheet(isPresented: $scannerPresented) {
      QRScannerViewController(scannedCode: $scannedCode)
    }
  }
  
}

struct QRScannerViewController: UIViewControllerRepresentable {

  @Binding var scannedCode: String?

  func makeUIViewController(context: Context) -> DataScannerViewController {
    let scanner = DataScannerViewController(
      recognizedDataTypes: [.barcode()],  // Supports QR Codes
      qualityLevel: .accurate,
      recognizesMultipleItems: false,
      isHighFrameRateTrackingEnabled: true,
      isHighlightingEnabled: true
    )
    scanner.delegate = context.coordinator
    return scanner
  }

  func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }

  class Coordinator: NSObject, DataScannerViewControllerDelegate {
    var parent: QRScannerViewController

    init(_ parent: QRScannerViewController) {
      self.parent = parent
    }

    func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
      if case .barcode(let barcode) = item {
        parent.scannedCode = barcode.payloadStringValue
        dataScanner.dismiss(animated: true)
      }
    }
  }
}

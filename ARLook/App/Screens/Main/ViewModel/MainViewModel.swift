//
//  MainViewModel.swift
//  ARLook
//
//  Created by Narek Aslanyan on 03.02.25.
//

import QRCode
import SwiftUI

class MainViewModel: ObservableObject {

  @Published var isShowScanner = false
  @Published var scannedCode: String?
  @Published var scale: CGFloat = 0
  @Published var isShowPicker: Bool = false
  @Published var selectedURL: URL?
  @Published var previewURL: URL? = nil
  @Published var image: CGImage?
  @Published var doc: QRCode.Document?
  @Published var savedFilePath: String?
  @Published var fileURL: URL?

  let context = CIContext()
  let filter = CIFilter.qrCodeGenerator()
  let modelManager = ModelManager.shared

  func setupDocument() {
    guard let scannedCode else { return }
    let doc = try? QRCode.Document(utf8String: scannedCode)
    doc?.design.shape.eye = QRCode.EyeShape.RoundedPointingIn()

    doc?.design.shape.onPixels = QRCode.PixelShape.Horizontal(
      insetFraction: 0.1, cornerRadiusFraction: 1)

    guard let logoImage = UIImage(named: "icon")?.cgImage else { return }
    doc?.logoTemplate = QRCode.LogoTemplate(
      image: logoImage,
      path: CGPath(
        rect: CGRect(
          x: 0.35,
          y: 0.35,
          width: 0.3,
          height: 0.3
        ),
        transform: nil
      )
    )
    self.doc = doc
    self.image = try? doc?.cgImage(CGSize(width: 800, height: 800))
  }

  func shareSheet(url: URL) {
    let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    let allScenes = UIApplication.shared.connectedScenes
    let activeScene = allScenes.first(where: { $0.activationState == .foregroundActive })
    if let windowScene = activeScene as? UIWindowScene {
      let rootViewController = windowScene.keyWindow?.rootViewController
      if UIDevice.current.userInterfaceIdiom == .pad {
        activityVC.popoverPresentationController?.sourceView = rootViewController?.view
        activityVC.popoverPresentationController?.sourceRect = .zero
      }
      DispatchQueue.main.async {
        rootViewController?.present(activityVC, animated: true, completion: nil)
      }
    }
  }

  func generateQRCode(from string: String) -> UIImage {
    filter.message = Data(string.utf8)
    guard let outputImage = filter.outputImage,
          let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
    else {
      return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    return UIImage(cgImage: cgImage)
  }

}

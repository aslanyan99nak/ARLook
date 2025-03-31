//
//  MainViewModel.swift
//  ARLook
//
//  Created by Narek Aslanyan on 03.02.25.
//

import Alamofire
import CoreImage.CIFilterBuiltins
import Foundation
import Moya
import QRCode
import SwiftUI

class MainViewModel: ObservableObject {

  @Published var isShowScanner = false
  @Published var isShowPopup = false
  @Published var scannedCode: String?
  @Published var isShowPicker: Bool = false
  @Published var selectedURL: URL?
  @Published var previewURL: URL? = nil
  @Published var image: UIImage?
  @Published var doc: QRCode.Document?
  @Published var savedFilePath: String?
  @Published var fileURL: URL?
  
  #if os(visionOS)
  @Published var sideMenuItems: [SideMenuItem] = SideMenuItem.allCases.filter { $0 != .view3DMode }
  @Published var selectedItem: SideMenuItem?
  #endif

  let context = CIContext()
  let filter = CIFilter.qrCodeGenerator()
  let modelManager = ModelManager.shared
  private let modelEnvironment: Provider = Provider<ModelEndpoint>()

  func setupDocument() {
    guard let scannedCode else { return }
    let doc = try? QRCode.Document(utf8String: "arlook://" + scannedCode)
    print("ScannedCode is: \(scannedCode)")
    doc?.design.shape.eye = QRCode.EyeShape.RoundedPointingIn()

    doc?.design.shape.onPixels = QRCode.PixelShape.Horizontal(
      insetFraction: 0.1, cornerRadiusFraction: 1
    )

    guard let logoImage = UIImage(named: "appIcon")?.cgImage else { return }
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
    guard let cgImage = try? doc?.cgImage(CGSize(width: 800, height: 800)) else { return }
    image = UIImage(cgImage: cgImage)
  }

  func generateQRCode(from string: String) -> UIImage {
    filter.message = Data(string.utf8)
    guard let outputImage = filter.outputImage,
      let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
    else {
      return UIImage(systemName: Image.xMarkCircleFill) ?? UIImage()
    }
    return UIImage(cgImage: cgImage)
  }

  func getModels() async {
    do {
      let response: [Model?] = try await modelEnvironment.request(.getList)
      let models = response.compactMap(\.self)
      models.forEach { print("File name 📁: \($0.mainFileName ?? "Not found")") }
    } catch {
      print("Can't get models")
    }
  }
  
//  func getFileURL(from scannedCode: String) -> URL? {
//    let fileManager = FileManager.default
//    guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
//    else { return nil }
//    guard let fileName = scannedCode.convertedFileNameFromURLString,
//          !fileName.isEmpty
//    else { return nil }
//    
////    viewModel.modelManager.checkFileExists(fileName: code) { isExists, url in
////      if let url, isExists {
////        viewModel.fileURL = url
////        viewModel.scannedCode = code
////      }
////    }
//    
//    let fileURL = documentsDirectory
//      .appendingPathComponent("\(scannedCode)")
//    return fileManager.fileExists(atPath: fileURL.path()) ? fileURL : nil
//  }
  
}

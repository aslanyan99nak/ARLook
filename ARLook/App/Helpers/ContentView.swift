//
//  ContentView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 30.01.25.
//

import CoreImage.CIFilterBuiltins
import RealityKit
import SwiftUI

struct ContentView: View {

  @AppStorage("name") private var name = "Anonymo"
  @AppStorage("emailAddress") private var emailAddress = "you@yoursite.com"

  @State private var isShowPicker: Bool = false
  @State private var selectedURL: URL?
  @State private var previewURL: URL? = URL(
    string: "https://nasa3d.arc.nasa.gov/detail/70-meter-dish")

  let context = CIContext()
  let filter = CIFilter.qrCodeGenerator()

  var qrImage: UIImage {
    generateQRCode(from: "\(name)\n\(emailAddress)")
  }

  var body: some View {
    NavigationStack {
      Form {
        TextField("Name", text: $name)
          .textContentType(.name)
          .font(.title)

        TextField("Email address", text: $emailAddress)
          .textContentType(.emailAddress)
          .font(.title)

        Image(uiImage: qrImage)
          .interpolation(.none)
          .resizable()
          .scaledToFit()
          .frame(width: 200, height: 200)

        Text(decodeQRCode(from: qrImage) ?? "not found")
          .foregroundStyle(.blue)
          .font(.title)

        Button {
          isShowPicker = true
        } label: {
          Text("Choose USDZ file")
            .foregroundStyle(.orange)
            .font(.title)
        }

        Button {
          if selectedURL != nil {
            previewURL = selectedURL
          }
        } label: {
          Text("Show 3D model")
            .foregroundStyle(.orange)
            .font(.title)
        }
        .quickLookPreview($previewURL)
      }
      .navigationTitle("Your code")
    }
    .sheet(isPresented: $isShowPicker) {
      DocumentPicker { url in
        self.selectedURL = url
      }
    }
  }

  func generateQRCode(from string: String) -> UIImage {
    filter.message = Data(string.utf8)

    if let outputImage = filter.outputImage {
      if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
        return UIImage(cgImage: cgImage)
      }
    }

    return UIImage(systemName: "xmark.circle") ?? UIImage()
  }

  func decodeQRCode(from image: UIImage) -> String? {
    guard let ciImage = CIImage(image: image) else { return nil }

    let detector = CIDetector(
      ofType: CIDetectorTypeQRCode,
      context: nil,
      options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
    )

    let features = detector?.features(in: ciImage) as? [CIQRCodeFeature]

    return features?.first?.messageString
  }

}

#Preview {
  ContentView()
}


//
//  MainCameraView.swift
//  ARLook
//
//  Created by Narek on 14.03.25.
//

import ARKit
import SwiftUI
import RealityKit

struct MainCameraView: View {

  @EnvironmentObject var mainCameraModel: MainCameraTrackingModel

  let emptyImage = Image(systemName: "camera")

  var body: some View {
    Text("Make Look Around Screen")
  }

}

extension CVPixelBuffer {

  var image: Image? {
    let ciImage = CIImage(cvPixelBuffer: self)
    let context = CIContext(options: nil)

    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
      return nil
    }

    let uiImage = UIImage(cgImage: cgImage)

    return Image(uiImage: uiImage)
  }

}

extension Image {

  @MainActor
  var uiImage: UIImage? {
    ImageRenderer(content: self).uiImage
  }

}

class MainCameraTrackingModel: TrackingModel, ObservableObject {

  private let cameraFrameProvider = CameraFrameProvider()

  @Published var pixelBuffer: CVPixelBuffer?

  @MainActor
  func run() async {
    // Check whether there's support for camera access; otherwise, handle this case.
    guard CameraFrameProvider.isSupported, let session else {
      print("CameraFrameProvider is not supported.")
      return
    }
    
    do {
      try await session.run([cameraFrameProvider])
      // Read the video formats that the left main camera supports.
      let formats = CameraVideoFormat.supportedVideoFormats(for: .main, cameraPositions: [.left])
      // Find the highest resolution format.
      let highResolutionFormat = formats.max { $0.frameSize.height < $1.frameSize.height }
      // Request an asynchronous sequence of camera frames.
      guard let highResolutionFormat,
        let cameraFrameUpdates = cameraFrameProvider.cameraFrameUpdates(for: highResolutionFormat)
      else {
        return
      }

      for await cameraFrame in cameraFrameUpdates {
        if let sample = cameraFrame.sample(for: .left) {
          // Update the `pixelBuffer` to render the frame's image.
          pixelBuffer = sample.pixelBuffer
        }
      }
    } catch {
      print("error is \(error)")
    }
  }

  @MainActor
  func snapShot() {
    guard let pixelBuffer,
      let uiImage = pixelBuffer.image?.uiImage
    else { return }
    
    UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
    print("✅ Snapshot saved to Photos!")
  }

}

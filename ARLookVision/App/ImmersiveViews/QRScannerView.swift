//
//  QRScannerView.swift
//  ARLook
//
//  Created by Narek on 05.03.25.
//

import ARKit
import Combine
import RealityKit
import SwiftUI

struct QRScannerScreen: View {

  @State private var arkitSession = ARKitSession()
  @State private var root = Entity()
  @State private var fadeCompleteSubscriptions: Set<AnyCancellable> = []

  var body: some View {
    RealityView { content in
      content.add(root)
    }
    .task {
      // Check whether there's support for barcode detection; otherwise, handle this case.
      guard BarcodeDetectionProvider.isSupported else {
        print("BarcodeDetectionProvider is not supported.")
        return
      }

      // Specify the symbologies you want to detect.
      let barcodeDetection = BarcodeDetectionProvider(symbologies: [.code128, .qr])

      do {
        try await arkitSession.run([barcodeDetection])

        for await update in barcodeDetection.anchorUpdates where update.event == .added {
          let anchor = update.anchor

          // Play an animation to indicate when the system detects a barcode.
          playAnimation(for: anchor)

          // Use the anchor's decoded contents and symbology to take action.
          print(
            """
            Payload: \(anchor.payloadString ?? "")
            Symbology: \(anchor.symbology)
            """)
        }
      } catch {
        // Handle the error.
        print(error)
      }
    }
  }

  func playAnimation(for anchor: BarcodeAnchor) {
    guard let scene = root.scene else { return }
    // Create a plane and size it to match the barcode.
    let extent = anchor.extent
    let entity = ModelEntity(
      mesh: .generatePlane(width: extent.x, depth: extent.z), materials: [UnlitMaterial(color: .green)])
    entity.components.set(OpacityComponent(opacity: 0))

    // Position the plane over the barcode.
    entity.transform = Transform(matrix: anchor.originFromAnchorTransform)
    root.addChild(entity)

    // Fade the plane in and out.
    do {
      let duration = 0.5
      let fadeIn = try AnimationResource.generate(
        with: FromToByAnimation<Float>(
          from: 0,
          to: 1.0,
          duration: duration,
          isAdditive: true,
          bindTarget: .opacity)
      )
      let fadeOut = try AnimationResource.generate(
        with: FromToByAnimation<Float>(
          from: 1.0,
          to: 0,
          duration: duration,
          isAdditive: true,
          bindTarget: .opacity))

      let fadeAnimation = try AnimationResource.sequence(with: [fadeIn, fadeOut])

      _ = scene.subscribe(
        to: AnimationEvents.PlaybackCompleted.self, on: entity,
        { _ in
          // Remove the plane after the animation completes.
          entity.removeFromParent()
        }
      ).store(in: &fadeCompleteSubscriptions)

      entity.playAnimation(fadeAnimation)
    } catch {
      // Handle the error.
    }
  }
  
}

#Preview(immersionStyle: .mixed) {
  QRScannerScreen()
}

struct QRScannerView: View {
  
  @EnvironmentObject var appModel: AppModel
  @Environment(\.openImmersiveSpace) var openImmersiveSpace
  @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
  
  var body: some View {
    openDismissQRScannerScreenButton
  }
  
  private var openDismissQRScannerScreenButton: some View {
    Button {
      Task {
        if appModel.immersiveSpaceId != nil {
          await dismissImmersiveSpace()
          appModel.immersiveSpaceId = nil
        } else {
          await openImmersiveSpace(id: ShowCase.qrScanner.immersiveSpaceId)
          appModel.immersiveSpaceId = ShowCase.qrScanner.immersiveSpaceId
        }
      }
    } label: {
      Text(appModel.immersiveSpaceId != nil ? "Dismiss QR Scanner" : "Show QR Scanner")
    }
  }
  
}

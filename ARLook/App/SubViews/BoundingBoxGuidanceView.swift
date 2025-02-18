//
//  BoundingBoxGuidanceView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import RealityKit
import SwiftUI

@MainActor
struct BoundingBoxGuidanceView: View {

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  var session: ObjectCaptureSession
  var hasDetectionFailed: Bool

  var body: some View {
    HStack {
      if let guidanceText = guidanceText {
        Text(guidanceText)
          .dynamicFont(weight: .bold)
          .foregroundStyle(.white)
          .transition(.opacity)
          .multilineTextAlignment(.center)
          .frame(maxWidth: horizontalSizeClass == .regular ? 400 : 360)
      }
    }
  }

  private var guidanceText: String? {
    switch session.state {
    case .ready: hasDetectionFailed ? LocString.detectionFailedGuidance : LocString.detectionSuccessedGuidance
    case .detecting: LocString.detectionGuidance
    default: nil
    }
  }

}

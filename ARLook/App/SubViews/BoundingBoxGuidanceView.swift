//
//  BoundingBoxGuidanceView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import SwiftUI
import RealityKit

@MainActor
struct BoundingBoxGuidanceView: View {

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  
  var session: ObjectCaptureSession
  var hasDetectionFailed: Bool

  var body: some View {
    HStack {
      if let guidanceText = guidanceText {
        Text(guidanceText)
          .font(.callout)
          .bold()
          .foregroundStyle(.white)
          .transition(.opacity)
          .multilineTextAlignment(.center)
          .frame(maxWidth: horizontalSizeClass == .regular ? 400 : 360)
      }
    }
  }
  
  private var guidanceText: String? {
    switch session.state {
    case .ready:
      if hasDetectionFailed {
        String.LocalizedString.detectionFailedGuidance
      } else {
        String.LocalizedString.detectionSuccessedGuidance
      }
    case .detecting:
      String.LocalizedString.detectionGuidance
    default: nil
    }
  }

}

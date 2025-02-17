//
//  CaptureButton.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import RealityKit
import SwiftUI

@MainActor
struct CaptureButton: View {

  @Binding var hasDetectionFailed: Bool
  var session: ObjectCaptureSession
  var isObjectFlipped: Bool

  var body: some View {
    Button {
      performAction()
    } label: {
      Text(buttonLabel)
        .dynamicFont(weight: .bold)
        .foregroundStyle(.white)
        .padding(.horizontal, 25)
        .padding(.vertical, 20)
        .background(.blue)
        .clipShape(Capsule())
    }
  }

  private var buttonLabel: String {
    if case .ready = session.state {
      String.LocString.continue
    } else {
      if !isObjectFlipped {
        String.LocString.startCapture
      } else {
        String.LocString.continue
      }
    }
  }

  private func performAction() {
    if case .ready = session.state {
      print("here")
      hasDetectionFailed = !(session.startDetecting())
    } else if case .detecting = session.state {
      session.startCapturing()
    }
  }

}

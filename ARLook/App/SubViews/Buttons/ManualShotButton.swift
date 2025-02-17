//
//  ManualShotButton.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import SwiftUI
import RealityKit

struct ManualShotButton: View {
  
  var session: ObjectCaptureSession

  var body: some View {
    Button {
      session.requestImageCapture()
    } label: {
      if session.canRequestImageCapture {
        Text(Image(systemName: "button.programmable"))
          .dynamicFont(size: 20)
          .foregroundStyle(.white)
      } else {
        Text(Image(systemName: "button.programmable"))
          .dynamicFont(size: 20)
          .foregroundStyle(.gray)
      }
    }
    .disabled(!session.canRequestImageCapture)
  }
  
}

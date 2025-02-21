//
//  ManualShotButton.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import RealityKit
import SwiftUI

struct ManualShotButton: View {

  var session: ObjectCaptureSession

  var body: some View {
    Button {
      session.requestImageCapture()
    } label: {
      Image(systemName: Image.shoot)
        .renderingMode(.template)
        .resizable()
        .frame(width: 40, height: 40)
        .foregroundStyle(session.canRequestImageCapture ? .white : .gray)
    }
    .disabled(!session.canRequestImageCapture)
  }

}

//
//  ResetBoundingBoxButton.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import SwiftUI
import RealityKit

struct ResetBoundingBoxButton: View {

  var session: ObjectCaptureSession

  var body: some View {
    Button {
      session.resetDetection()
    } label: {
      buttonContentView
    }
  }
  
  private var buttonContentView: some View {
    VStack(spacing: 6) {
      Image(.resetBox)
        .renderingMode(.template)
        .resizable()
        .frame(width: 40, height: 40)
        .foregroundStyle(.white)

      Text(LocString.resetBox)
        .opacity(0.7)
    }
    .foregroundStyle(.white)
    .fontWeight(.semibold)
  }

}

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
        .aspectRatio(contentMode: .fit)
        .frame(width: 30)
        .foregroundStyle(.white)

      Text(String.LocString.resetBox)
        .dynamicFont()
        .opacity(0.7)
    }
    .foregroundStyle(.white)
    .fontWeight(.semibold)
  }

}

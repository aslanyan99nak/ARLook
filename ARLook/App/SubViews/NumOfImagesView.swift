//
//  NumOfImagesView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import RealityKit
import SwiftUI

struct NumOfImagesView: View {

  var session: ObjectCaptureSession

  private var numOfImagesString: String {
    String(
      format: LocString.numOfImages,
      session.numberOfShotsTaken,
      session.maximumNumberOfInputImages
    )
  }

  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: Image.photo)
        .resizable()
        .frame(width: 24, height: 24)

      Text(numOfImagesString)
        .dynamicFont(weight: .bold, design: .rounded)
    }
    .foregroundStyle(session.feedback.contains(.overCapturing) ? .red : .white)
  }

}

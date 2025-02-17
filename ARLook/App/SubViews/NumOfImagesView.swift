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
      format: String.LocString.numOfImages,
      session.numberOfShotsTaken,
      session.maximumNumberOfInputImages
    )
  }

  var body: some View {
    VStack(spacing: 8) {
      Text(Image(systemName: "photo"))

      Text(numOfImagesString)
        .dynamicFont(weight: .bold, design: .rounded)
    }
    .foregroundStyle(session.feedback.contains(.overCapturing) ? .red : .white)
  }

}

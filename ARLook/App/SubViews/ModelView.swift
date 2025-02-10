//
//  ModelView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import SwiftUI

struct ModelView: View {

  @State private var isLoading = true

  var modelFile: URL
  let endCaptureCallback: () -> Void

  var body: some View {
    ZStack {
      if !isLoading {
        ARQuickLookController(modelFile: modelFile, endCaptureCallback: endCaptureCallback)
      } else {
        
        CircularProgressView()
          .scaleEffect(3)
      }
    }
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self.isLoading = false
      }
    }
  }
}

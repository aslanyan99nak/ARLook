//
//  HandTrackingView.swift
//  ARLook
//
//  Created by Narek on 19.03.25.
//

import SwiftUI
import RealityKit

struct HandTrackingView: View {
  
  @EnvironmentObject var handTrackingViewModel: HandTrackingViewModel
  
  var body: some View {
    RealityView { content in
      if let contentEntity = handTrackingViewModel.setupContentEntity() {
        content.add(contentEntity)
      }
    }
    .task {
      await handTrackingViewModel.runSession()
    }
    .task {
      await handTrackingViewModel.processHandUpdates()
    }
  }
  
}

#Preview {
  HandTrackingView()
}

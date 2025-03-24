//
//  PlaneClassificationImmersiveView.swift
//  ARLook
//
//  Created by Narek on 14.03.25.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct PlaneClassificationImmersiveView: View {
  
  @EnvironmentObject var model: PlaneClassificationTrackingModel

  var body: some View {
    RealityView { content in
      content.add(model.rootEntity)
    }
    .task {
      await model.run()
    }
    .onDisappear {
      // TODO: - Reset content
    }
  }
}

#Preview {
  PlaneClassificationImmersiveView()
}

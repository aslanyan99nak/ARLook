//
//  WorldScaningImmersiveView.swift
//  ARLook
//
//  Created by Narek on 13.03.25.
//

import RealityKit
import SwiftUI

struct WorldScaningImmersiveView: View {

  @EnvironmentObject var model: WorldScaningTrackingModel

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
  WorldScaningImmersiveView()
}

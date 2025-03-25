//
//  LookAroundImmersiveView.swift
//  ARLook
//
//  Created by Narek on 20.03.25.
//

import ARKit
import Combine
import Foundation
import RealityKit
import SwiftUI

struct LookAroundImmersiveView: View {

  @EnvironmentObject var viewModel: LookAroundImmersiveViewModel
  @EnvironmentObject var appModel: AppModel
  @EnvironmentObject var handTracking: HandTrackingViewModel
  @StateObject var gestureModel = GestureModel()
  @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
  @State private var subscription: EventSubscription?

  var body: some View {
    RealityView { content in
      if let handsContentEntity = handTracking.setupContentEntity() {
        content.add(handsContentEntity)
      }
      content.add(viewModel.setupContentEntity())

      subscription = content.subscribe(to: CollisionEvents.Began.self, on: nil) { collisionEvent in
        print("💥 Collision between \(collisionEvent.entityA.name) and \(collisionEvent.entityB.name)")
        if collisionEvent.entityA.name.contains(".usdz") {
          let entity = collisionEvent.entityA
          viewModel.deleteHighlightedForEntity()
          viewModel.addHighlightForEntity(for: entity)
          viewModel.setCurrentEntity(entity)
        } else if collisionEvent.entityB.name == ".usdz" {
          let entity = collisionEvent.entityB
          viewModel.deleteHighlightedForEntity()
          viewModel.addHighlightForEntity(for: entity)
          viewModel.setCurrentEntity(entity)
        }
      }
    }
    .installGestures()
    .onLoad {
      gestureModel.gestureAction = { gesture in
        switch gesture {
        case .tap: print("LookAroundImmersiveView Tapped!!!")
        case .middleTap: addSelectedEntity()
        case .heart: viewModel.resetContent()
        case .custom: viewModel.addSpaceStation()
        case .cross: viewModel.deleteSelectedEntity()
        case .unknown: break
        }
      }
    }
    .task {
      await handTracking.runSession()
    }
    .task {
      await handTracking.processHandUpdates()
    }
    .task {
      await gestureModel.start()
    }
    .task {
      await gestureModel.publishHandTrackingUpdates()
    }
    .onDisappear {
      Task {
        if appModel.immersiveSpaceId != nil {
          await dismissImmersiveSpace()
          appModel.immersiveSpaceId = nil
        }
        viewModel.resetContent()
      }
    }
  }

  private func addSelectedEntity() {
    guard let entity = viewModel.getCurrentEntity(),
      let placementLocation = handTracking.getLeftFingerPosition()
    else { return }
    entity.setPosition(placementLocation, relativeTo: nil)
    entity.setScale(.init(x: 1, y: 1, z: 1), relativeTo: nil)
    viewModel.add(entity)
  }

  private func addArrowEntity() {
    guard let arrowEntity = viewModel.getArrowEntity(),
      let placementLocation = handTracking.getLeftFingerPosition()
    else { return }
    arrowEntity.setPosition(placementLocation, relativeTo: nil)
    arrowEntity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
    viewModel.add(arrowEntity)
  }

}

#Preview {
  LookAroundImmersiveView()
}

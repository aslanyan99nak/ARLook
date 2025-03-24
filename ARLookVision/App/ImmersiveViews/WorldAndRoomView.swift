//
//  WorldAndRoomView.swift
//  ARLook
//
//  Created by Narek on 17.03.25.
//

import ARKit
import RealityKit
import SwiftUI

struct WorldAndRoomView: View {
  
  @EnvironmentObject var appModel: AppModel
  @EnvironmentObject var handTrackingViewModel: HandTrackingViewModel
  @StateObject var gestureModel = GestureModel()
  @Environment(RoomState.self) var roomState
  @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
  @State private var previewSphere: Entity?
  @State private var updateFacingWallTask: Task<Void, Never>? = nil

  var body: some View {
    RealityView { content in
      content.add(roomState.setupContentEntity())
      if let handsContentEntity = handTrackingViewModel.setupContentEntity() {
        content.add(handsContentEntity)
      }
      updateFacingWallTask = run(roomState.updateFacingWall, withFrequency: 10)
    }
    .onLoad {
      gestureModel.gestureAction = { gesture in
        if case .tap = gesture {
          roomState.processTapOnEntity()
        }
      }
    }
    .onDisappear {
      Task {
        if appModel.immersiveSpaceId != nil {
          await dismissImmersiveSpace()
          appModel.immersiveSpaceId = nil
        }
        updateFacingWallTask?.cancel()
        // TODO: - Reset content
      }
    }
    .task {
      await gestureModel.start()
    }
    .task {
      await gestureModel.publishHandTrackingUpdates()
    }
    .task {
      await roomState.runSession()
    }
    .task {
      await roomState.monitorSessionUpdates()
    }
    .task {
      await roomState.processRoomTrackingUpdates()
    }
    // FOR HAND TRACKING
    .task {
      await handTrackingViewModel.runSession()
    }
    .task {
      await handTrackingViewModel.processHandUpdates()
    }
  }
}

extension WorldAndRoomView {
  /// Runs a given function at an approximate frequency.
  func run(_ function: @escaping () -> Void, withFrequency freqHz: UInt64) -> Task<Void, Never> {
    return Task {
      while true {
        if Task.isCancelled {
          return
        }

        // Sleeps for 1 s / Hz before calling the function.
        let nanoSecondsToSleep: UInt64 = NSEC_PER_SEC / freqHz
        do {
          try await Task.sleep(nanoseconds: nanoSecondsToSleep)
        } catch {
          // Sleep fails when the Task is in a canceled state. Exit the loop.
          return
        }

        function()
      }
    }
  }
}

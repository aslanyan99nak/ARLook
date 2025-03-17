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
  
  @Environment(RoomState.self) var roomState
  @State var previewSphere: Entity?
  @State private var updateFacingWallTask: Task<Void, Never>? = nil
  
  @StateObject var handTrackingViewModel = HandTrackingViewModel()

  var body: some View {
    RealityView { content in
      content.add(roomState.setupContentEntity())
      content.add(handTrackingViewModel.setupContentEntity())
      updateFacingWallTask = run(roomState.updateFacingWall, withFrequency: 10)
    }
    .onAppear {
      roomState.isImmersive = true
    }
    .onDisappear {
      roomState.isImmersive = false
      updateFacingWallTask?.cancel()
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
    .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded { value in
      print("Tapped!!!")
//      Task {
//        await handTrackingViewModel.placeCube()
//      }
      roomState.processTapOnEntity()
    })
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

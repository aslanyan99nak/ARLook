//
//  RoomClassificationTrackingModel.swift
//  ARLook
//
//  Created by Narek on 17.03.25.
//

import RealityKit
import SwiftUI

class RoomClassificationTrackingModel: TrackingModel, ObservableObject {
    
  var roomParentEntity = Entity()
  
  @Published var selectedURL: URL?
  
  @MainActor
  func saveModelEntity() {
    Task {
      await ModelManager.shared.saveFile(
        fileName: "Room.reality",
        entity: roomParentEntity
      ) { [weak self] isSuccess, url in
        DispatchQueue.main.async { [weak self] in
          guard let self else { return }
          if isSuccess {
            selectedURL = url
          }
        }
      }
    }
  }
  
}

//
//  AppModel.swift
//  ARLookVision
//
//  Created by Narek on 04.03.25.
//

import SwiftUI

class AppModel: ObservableObject {
  
  @Published var immersiveSpaceId: String? = nil
  @Published var windowId: String? = nil
  @Published var isPlayVideo: Bool = false
  @Published var navigationPath: [ShowCase] = []
  @Published var material: [ShowCase] = []
  
}

enum ShowCase: String, Identifiable, CaseIterable, Equatable {
  
  case worldScaning
  case planeClassification
  case qrScanner
  case roomTracking
  case lookAround

  var id: Self { self }
  var name: String { rawValue }

  var detail: String {
    switch self {
    case .worldScaning: "Use ARKit to scene the world"
    case .planeClassification: "Use ARKit to classification the plane"
    case .qrScanner: "Use ARKit to scan QR code"
    case .roomTracking: "Use ARKit to track the room"
    case .lookAround: "Use ARKit to use main camera frame"
    }
  }

  var windowId: String? {
    switch self {
    default: nil
    }
  }

  var immersiveSpaceId: String {
    switch self {
    case .worldScaning: "WorldScaning"
    case .planeClassification: "PlaneClassification"
    case .qrScanner: "QRScanner"
    case .roomTracking: "RoomTracking"
    case .lookAround: "LookAround"
    }
  }
  
}

enum WindowCase: String {
  
  case changeMaterialColor = "ChangeMaterialColor"
  case searchScreen = "SearchScreen"
  
}

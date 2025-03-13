//
//  ImmersiveModel.swift
//  ARLook
//
//  Created by Narek on 13.03.25.
//

import SwiftUI

class ImmersiveModel: ObservableObject {
  
  @Published var immersiveSpaceId: String? = nil
  @Published var windowId: String? = nil
  @Published var isPlayVideo: Bool = false
  @Published var navigationPath: [ShowCase] = []
  @Published var material: [ShowCase] = []
  
}

enum ShowCase: String, Identifiable, CaseIterable, Equatable {
  
  case PanoramaVideo, WorldReconstruction, PlaneClassification, SharePlay, HandTracking, TargetPlane, Gesture, Window

  var id: Self { self }
  var name: String { rawValue }

  var detail: String {
    switch self {
    case .PanoramaVideo: "Show Panorama Video in visionOS"
    case .WorldReconstruction: "Use ARKit to scene the world"
    case .PlaneClassification: "Use ARKit to classification the plane"
    case .SharePlay: "Show the SharePlay in visionOS"
    case .HandTracking: "Tracking the hand movement"
    case .TargetPlane: "Place Entity onto target plane"
    case .Gesture: "Gesture in 3D"
    case .Window: "What window can show in 3D space"
    }
  }

  //    var windowDestination: AnyView? {
  //        switch self {
  //            case .PanoramaVideo: AnyView(VideoController())
  //            case .SharePlay: AnyView(PlayTogtherView())
  //            case .Window: AnyView(WindowView())
  //            default: nil
  //        }
  //    }

  var windowId: String? {
    switch self {
    default: nil
    }
  }

  var volumeId: String? {
    switch self {
    case .Gesture: "Gesture"
    default: nil
    }
  }

  var immersiveSpaceId: String? {
    switch self {
    case .WorldReconstruction: "WorldScaning"
    case .PlaneClassification: "PalneClassification"
    case .HandTracking: "HandTracking"
    case .TargetPlane: "TargetPlane"
    default: nil
    }
  }
}

//
//  AppModel.swift
//  ARLookVision
//
//  Created by Narek on 04.03.25.
//

import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
  
  let immersiveSpaceID = "ImmersiveSpace"
  
  enum ImmersiveSpaceState {
    
    case closed
    case inTransition
    case open
    
  }
  
  var immersiveSpaceState = ImmersiveSpaceState.closed
  
}

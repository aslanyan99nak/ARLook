//
//  FeedbackMessages.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import Foundation
import RealityKit
import SwiftUI

final class FeedbackMessages {
  /// Returns the human readable string to display for the given feedback.
  ///
  /// If there's more than one feedback entry, this method concatenates the entries together with a new line in between them.
  @MainActor
  static func getFeedbackString(for feedback: ObjectCaptureSession.Feedback) -> String? {
    return switch feedback {
    case .objectTooFar: String.LocString.objectTooFar
    case .objectTooClose: String.LocString.objectTooClose
    case .environmentTooDark, .environmentLowLight: String.LocString.environmentLightRequired
    case .movingTooFast: String.LocString.movingTooFast
    case .outOfFieldOfView: String.LocString.outOfFieldOfView
    default: nil
    }
  }
}

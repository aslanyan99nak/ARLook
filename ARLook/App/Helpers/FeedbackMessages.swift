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
    case .objectTooFar: LocString.objectTooFar
    case .objectTooClose: LocString.objectTooClose
    case .environmentTooDark, .environmentLowLight: LocString.environmentLightRequired
    case .movingTooFast: LocString.movingTooFast
    case .outOfFieldOfView: LocString.outOfFieldOfView
    default: nil
    }
  }
}

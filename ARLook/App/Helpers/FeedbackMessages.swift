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
    case .objectTooFar: String.LocalizedString.objectTooFar
    case .objectTooClose: String.LocalizedString.objectTooClose
    case .environmentTooDark, .environmentLowLight: String.LocalizedString.environmentLightRequired
    case .movingTooFast: String.LocalizedString.movingTooFast
    case .outOfFieldOfView: String.LocalizedString.outOfFieldOfView
    default: nil
    }
  }
}

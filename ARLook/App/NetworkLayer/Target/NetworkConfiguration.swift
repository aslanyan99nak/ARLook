//
//  NetworkConfiguration.swift
//  ARLook
//
//  Created by Narek on 17.02.25.
//

import Alamofire
import Foundation
import Moya
import SwiftUI

/// Confige network
enum NetworkConfiguration {
  /// Logger for network
  /// - Default: Enable
  static let networkLogger = NetworkLoggerPlugin(
    configuration: NetworkLoggerPlugin.Configuration(logOptions: .verbose))

  /// Configuration for session manager
  static var sessionManager: Session {
    let configuration = URLSessionConfiguration.default
    configuration.headers = .default
    configuration.timeoutIntervalForRequest = 90
    configuration.timeoutIntervalForResource = 90
    configuration.requestCachePolicy = .useProtocolCachePolicy
    return Alamofire.Session(configuration: configuration)
  }

  /// Block for application network indicator
  typealias NetworkIndicator = (NetworkActivityChangeType, TargetType) -> Void

  static var networkActivityIndicator: NetworkIndicator {
    return { (change: NetworkActivityChangeType, _: TargetType) in
      switch change {
      case .began: print("----- Began -----")
      case .ended: print("----- Ended -----")
      }
    }
  }
  
}

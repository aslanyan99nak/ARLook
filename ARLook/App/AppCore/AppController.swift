//
//  AppController.swift
//  ARLook
//
//  Created by Narek on 17.02.25.
//


final class AppController {
  
  static var shared = AppController()

  var environment: Env {
    #if DEBUG
    return .local
    #else
    return .production
    #endif
  }

  static var isDebug: Bool {
    #if DEBUG
    return true
    #else
    return false
    #endif
  }
  
}

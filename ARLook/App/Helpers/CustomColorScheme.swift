//
//  CustomColorScheme.swift
//  ARLook
//
//  Created by Narek Aslanyan on 14.02.25.
//

import SwiftUI

enum CustomColorScheme: Int, CaseIterable, Identifiable, Codable {

  static var defaultKey = "customColorScheme"
  static var defaultValue = CustomColorScheme.system

  case system = 0
  case light = 1
  case dark = 2

  var id: Int {
    self.rawValue
  }

  var colorScheme: ColorScheme? {
    switch self {
    case .system: nil
    case .light: .light
    case .dark: .dark
    }
  }

  var label: String {
    switch self {
    case .system: "System"
    case .light: "Light"
    case .dark: "Dark"
    }
  }
  
  var icon: Image {
    switch self {
    case .system: Image(systemName: "circle.righthalf.fill")
    case .light: Image(systemName: "sun.max")
    case .dark: Image(systemName: "moon")
    }
  }
  
}

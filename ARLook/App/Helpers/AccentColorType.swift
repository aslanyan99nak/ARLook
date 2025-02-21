//
//  AccentColorType.swift
//  ARLook
//
//  Created by Narek Aslanyan on 14.02.25.
//

import SwiftUI

enum AccentColorType: String, CaseIterable {
  
  static var defaultKey = "accentColorType"
  static var defaultValue = AccentColorType.blue
  
  case blue, purple, pink, red, orange
  case yellow, green, lightGreen, mint, cyan
  
  var color: Color {
    switch self {
    case .blue: Color.blue
    case .purple: Color.purple
    case .pink: Color.pink
    case .red: Color.red
    case .orange: Color.orange
    case .yellow: Color.yellow
    case .green: Color.green
    case .lightGreen: Color.lightGreen
    case .mint: Color.mint
    case .cyan: Color.cyan
    }
  }
  
}

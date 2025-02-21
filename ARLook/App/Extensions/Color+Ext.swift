//
//  Color+Ext.swift
//  ARLook
//
//  Created by Narek Aslanyan on 14.02.25.
//

import SwiftUI

extension Color {

  func adjust(
    hue: CGFloat = 0,
    saturation: CGFloat = 0,
    brightness: CGFloat = 0,
    opacity: CGFloat = 1
  ) -> Color {
    let color = UIColor(self)
    var currentHue: CGFloat = 0
    var currentSaturation: CGFloat = 0
    var currentBrigthness: CGFloat = 0
    var currentOpacity: CGFloat = 0

    if color.getHue(
      &currentHue,
      saturation: &currentSaturation,
      brightness: &currentBrigthness,
      alpha: &currentOpacity
    ) {
      return Color(
        hue: currentHue + hue,
        saturation: currentSaturation + saturation,
        brightness: currentBrigthness + brightness,
        opacity: currentOpacity + opacity
      )
    }
    return self
  }

}

extension Color {

  static let green2 = Color(red: 60 / 255, green: 136 / 255, blue: 37 / 255)
  static let green3 = Color(red: 143 / 255, green: 197 / 255, blue: 112 / 255)
  static let lightGreen = Color(red: 173 / 255, green: 255 / 255, blue: 47 / 255)
  static let darkGray = Color(red: 105 / 255, green: 105 / 255, blue: 105 / 255)

}



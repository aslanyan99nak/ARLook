//
//  LinearGradientBackgroundView.swift
//  ARLook
//
//  Created by Narek on 02.04.25.
//

import SwiftUI

struct LinearGradientBackgroundView: View {

  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue

  var body: some View {
    LinearGradient(
      colors: [
        accentColorType.color.opacity(0.2),
        .white.opacity(0.1),
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

}

//
//  VisualEffectRoundedCorner.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import SwiftUI

struct VisualEffectRoundedCorner: ViewModifier {

  func body(content: Content) -> some View {
    content
      .padding(16.0)
      .font(.subheadline)
      .bold()
      .foregroundStyle(.white)
      .background(.ultraThinMaterial)
      .environment(\.colorScheme, .dark)
      .cornerRadius(15)
      .multilineTextAlignment(.center)
  }

}

//
//  ScaleHoverEffect.swift
//  ARLook
//
//  Created by Narek on 05.03.25.
//

import SwiftUI

@available(visionOS 2.0, *)
struct ScaleHoverEffect: CustomHoverEffect {

  func body(content: Content) -> some CustomHoverEffect {
    content.hoverEffect { effect, isActive, proxy in
      effect.animation(.easeOut) {
        $0.scaleEffect(isActive ? 1.2 : 1, anchor: .top)
      }
    }
  }

}

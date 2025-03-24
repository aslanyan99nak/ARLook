//
//  ScaleHoverEffect.swift
//  ARLook
//
//  Created by Narek on 05.03.25.
//

import SwiftUI

@available(visionOS 2.0, *)
struct ScaleHoverEffect: CustomHoverEffect {
  
  var scale: CGFloat = 1.2

  func body(content: Content) -> some CustomHoverEffect {
    content.hoverEffect { effect, isActive, proxy in
      effect.animation(.easeOut) {
        $0.scaleEffect(isActive ? scale : 1, anchor: .top)
      }
    }
  }

}

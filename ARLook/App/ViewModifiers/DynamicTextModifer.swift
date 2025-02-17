//
//  DynamicTextModifer.swift
//  ARLook
//
//  Created by Narek Aslanyan on 14.02.25.
//

import SwiftUI

struct DynamicTextModifer: ViewModifier {
  
  @AppStorage("textSize") private var textSize: Double = 0
  
  var size: CGFloat = 16
  let weight: Font.Weight
  let design: Font.Design

  func body(content: Content) -> some View {
    content
      .font(
        Font.system(
          size: size + textSize,
          weight: weight,
          design: design
        )
      )
  }
    
}

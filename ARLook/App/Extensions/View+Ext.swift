//
//  View+Ext.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import SwiftUI

extension View {
  @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content)
    -> some View
  {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}

extension View {
  
  func customColorScheme(_ customColorScheme: Binding<CustomColorScheme>) -> some View {
    self.modifier(CustomColorSchemeViewModifier(customColorScheme))
  }
  
}

extension View {
  
  func dynamicFont(
    size: CGFloat = 16,
    weight: Font.Weight = .regular,
    design: Font.Design = .default
  ) -> some View {
    modifier(DynamicTextModifer(size: size, weight: weight, design: design))
  }
  
}

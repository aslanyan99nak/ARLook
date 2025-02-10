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


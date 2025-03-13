//
//  CircleButton.swift
//  ARLook
//
//  Created by Narek Aslanyan on 14.02.25.
//

import SwiftUI

struct CircleButton: View {

  let item: Color
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Circle()
      .fill(item)
      .frame(width: 32, height: 32)
      .overlay {
        Circle()
          .stroke(item.adjust(brightness: -0.2), lineWidth: 2)
      }
      .padding(5)
      .overlay {
        if isSelected {
          Circle()
            .stroke(Color.accentColor, lineWidth: 3)
        }
      }
      .onTapGesture(perform: action)
      .if(UIDevice.isVision) { view in
        view
          .padding(4)
          .background(.regularMaterial)
          .clipShape(Circle())
      }
      .scaleHoverEffect()
  }
  
}

#Preview {
  CircleButton(
    item: Color.blue,
    isSelected: true,
    action: {}
  )
}

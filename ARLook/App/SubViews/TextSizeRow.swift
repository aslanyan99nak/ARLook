//
//  TextSizeRow.swift
//  ARLook
//
//  Created by Narek Aslanyan on 14.02.25.
//

import SwiftUI

struct TextSizeRow: View {
  
  @AppStorage("textSize") private var textSize: Double = 0 // Default
  
  var body: some View {
    HStack(spacing: 0) {
      Text("Text Size")
        .dynamicFont()
        .minimumScaleFactor(0.5)
        .padding(.trailing, 8)

      Spacer()

      sliderView
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .background(Material.regular)
    .clipShape(RoundedRectangle(cornerRadius: 16))
  }
  
  private var sliderView: some View {
    Slider(value: $textSize, in: 0...10, step: 1)
      .background {
        HStack {
          ForEach(0..<5) { i in
            Color.gray
              .frame(width: 2, height: 8)
            if i < 4 {
              Spacer()
            }
          }
        }
        .padding(.horizontal, 12)
      }
  }
  
}

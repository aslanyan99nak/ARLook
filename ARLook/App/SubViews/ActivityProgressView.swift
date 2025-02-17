//
//  ActivityProgressView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 14.02.25.
//

import SwiftUI

struct ActivityProgressView: View {

  @State private var isAnimate: Bool = false

  let progress: Float
  var color: Color = .blue
  var scale: CGFloat = 1

  var body: some View {
    ZStack {
      Circle()
        .stroke(lineWidth: 40)
        .opacity(0.1)
        .foregroundStyle(color)

      Circle()
        .trim(from: 0.0, to: CGFloat(progress))
        .stroke(style: StrokeStyle(lineWidth: 40, lineCap: .round))
        .foregroundStyle(color)

      Text(progress, format: .percent.precision(.fractionLength(0)))
        .dynamicFont(weight: .bold)
        .monospacedDigit()
    }
    .frame(width: scale * 150, height: scale * 150)
  }

}

#Preview {
  ActivityProgressView(
    progress: 0.3,
    color: Color.orange,
    scale: 1
  )
}

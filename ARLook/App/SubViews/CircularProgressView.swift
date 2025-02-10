//
//  CircularProgressView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import SwiftUI

struct CircularProgressView: View {

  @Environment(\.colorScheme) var colorScheme

  var tintColor: Color?

  private var tint: Color { colorScheme == .light ? .black : .white }

  var body: some View {
    ProgressView()
      .progressViewStyle(
        CircularProgressViewStyle(tint: tintColor ?? tint)
      )
  }

}

#Preview {
  CircularProgressView(tintColor: .red)
    .background(Color.blue)
}

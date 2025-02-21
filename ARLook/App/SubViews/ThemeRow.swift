//
//  ThemeRow.swift
//  ARLook
//
//  Created by Narek Aslanyan on 14.02.25.
//

import SwiftUI

struct ThemeRow: View {

  @AppStorage(CustomColorScheme.defaultKey) var colorScheme = CustomColorScheme.defaultValue

  let mode: CustomColorScheme

  var body: some View {
    HStack(spacing: 8) {
      Text(mode.label)
        .dynamicFont()
        .tag(mode)

      mode.icon
        .resizable()
        .frame(width: 16, height: 16)

      Spacer()

      if mode == colorScheme {
        Image(systemName: Image.checkMarkCircle)
          .renderingMode(.template)
          .resizable()
          .frame(width: 16, height: 16)
          .foregroundStyle(Color.green)
      }
    }
    .contentShape(Rectangle())
  }

}

#Preview {
  ThemeRow(mode: .dark)
}

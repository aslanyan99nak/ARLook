//
//  ThemeRow.swift
//  ARLook
//
//  Created by Narek Aslanyan on 14.02.25.
//

import SwiftUI

struct ThemeRow: View {

  @AppStorage(CustomColorScheme.defaultKey) var colorScheme = CustomColorScheme.defaultValue
  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue
  
  let mode: CustomColorScheme

  var body: some View {
    HStack(spacing: 8) {
      mode.icon
        .renderingMode(.template)
        .resizable()
        .frame(width: 16, height: 16)
        .foregroundStyle(mode == colorScheme ? accentColorType.color : UIDevice.isVision ? .white : .gray)
      
      Text(mode.label)
        .dynamicFont()
        .tag(mode)

      Spacer()

      if mode == colorScheme {
        Image(systemName: Image.checkMarkCircle)
          .renderingMode(.template)
          .resizable()
          .frame(width: 16, height: 16)
          .foregroundStyle(accentColorType.color)
      } else {
        Image(systemName: "circle")
          .renderingMode(.template)
          .resizable()
          .frame(width: 16, height: 16)
          .foregroundStyle(UIDevice.isVision ? Color.white : Color.gray)
      }
    }
    .contentShape(Rectangle())
  }

}

#Preview {
  ThemeRow(mode: .dark)
}

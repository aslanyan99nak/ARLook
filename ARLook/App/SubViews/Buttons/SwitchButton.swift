//
//  SwitchButton.swift
//  ARLook
//
//  Created by Narek Aslanyan on 10.02.25.
//

import SwiftUI

struct SwitchButton: View {
  
  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue
  @Environment(\.colorScheme) var colorScheme
  @Binding var isList: Bool
  
  var body: some View {
    HStack(spacing: 0) {
      listButton
      
      Divider()
        .overlay { colorScheme == .dark ? Color.white : Color.black }
      
      gridButton
    }
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .background(
      RoundedRectangle(cornerRadius: 8)
        .stroke(lineWidth: 0.5)
        .fill(colorScheme == .dark ? Color.white : Color.black)
    )
  }
  
  private var listButton: some View {
    Button {
      withAnimation(.easeInOut(duration: 0.5)) {
        isList = true
      }
    } label: {
      ZStack {
        Color.gray.opacity(isList ? 0.3 : 0.1)
        
        Image(systemName: Image.row)
          .renderingMode(.template)
          .resizable()
          .frame(width: 20, height: 12)
          .foregroundStyle(isList ? accentColorType.color : Color.gray.opacity(0.5))
      }
    }
  }
  
  private var gridButton: some View {
    Button {
      withAnimation(.easeInOut(duration: 0.5)) {
        isList = false
      }
    } label: {
      ZStack {
        Color.gray.opacity(isList ? 0.1 : 0.3)

        Image(systemName: Image.grid)
          .renderingMode(.template)
          .resizable()
          .frame(width: 20, height: 20)
          .foregroundStyle(isList ? Color.gray.opacity(0.5) : accentColorType.color)
      }
    }
  }
  
}

#Preview {
  SwitchButton(isList: .constant(false))
    .frame(width: 200, height: 100)
}

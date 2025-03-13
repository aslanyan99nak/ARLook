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
    content
  }

  @ViewBuilder
  private var content: some View {
    if UIDevice.isVision {
      visionContent
    } else {
      iOSContent
    }
  }

  private var visionContent: some View {
    HStack(spacing: 0) {
      listButton

      Divider()
        .overlay { Color.white }

      gridButton
    }
    .clipShape(Capsule())
    .background(
      Capsule()
        .stroke(lineWidth: 0.5)
        .fill(Color.white)
    )
  }

  private var iOSContent: some View {
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
    ZStack {
      Color.gray.opacity(isList ? 0.3 : 0.1)

      Image(systemName: Image.row)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 20)
        .scaleHoverEffect()
        .if(isList) { view in
          view
            .foregroundStyle(accentColorType.color)
        }
        .if(!isList) { view in
          view
            .foregroundStyle(Color.gray.opacity(0.5))
        }
    }
    .onTapGesture {
      withAnimation(.easeInOut(duration: 0.5)) {
        isList = true
      }
    }
  }

  private var gridButton: some View {
    ZStack {
      Color.gray.opacity(isList ? 0.1 : 0.3)

      Image(systemName: Image.grid)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 20)
        .scaleHoverEffect()
        .if(isList) { view in
          view
            .foregroundStyle(Color.gray.opacity(0.5))
        }
        .if(!isList) { view in
          view
            .foregroundStyle(accentColorType.color)
        }
    }
    .onTapGesture {
      withAnimation(.easeInOut(duration: 0.5)) {
        isList = false
      }
    }
  }

}

#Preview {
  @Previewable @State var isList: Bool = false
  
  SwitchButton(isList: $isList)
    .frame(width: 200, height: 100)
}

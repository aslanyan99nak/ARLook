//
//  SwitchButton.swift
//  ARLook
//
//  Created by Narek Aslanyan on 10.02.25.
//

import SwiftUI

struct SwitchButton: View {

  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue
  @AppStorage(CustomColorScheme.defaultKey) var customColorScheme = CustomColorScheme.defaultValue
  @Environment(\.colorScheme) var colorScheme

  @Binding var isList: Bool

  private let size: CGSize

  private var offsetX: CGFloat {
    let offset = calculateSegmentOffset(size)
    return isList ? offset + 4 : offset - 4
  }

  private var iconOffsetX: CGFloat {
    return isSmall ? (isList ? 4 : -4) : 0
  }

  private var isDarkMode: Bool {
    customColorScheme == .dark || customColorScheme == .system && colorScheme == .dark
  }

  private var capsuleColor: Color { isDarkMode ? .black : .white }

  private var isSmall: Bool { size.width < 320 }

  public init(isList: Binding<Bool>, size: CGSize) {
    self._isList = isList
    self.size = size
  }

  var body: some View {
    ZStack(alignment: .leading) {
      bigCapsuleView
      smallCapsuleView
      segmentedItemView
    }
  }

  private var bigCapsuleView: some View {
    Capsule()
      .frame(width: abs(size.width), height: abs(size.height))
      .foregroundStyle(.gray)
      .opacity(0.2)
  }

  private var smallCapsuleView: some View {
    Capsule()
      .fill(Color.clear)
      .if(UIDevice.isVision) { view in
        view
          .background(.ultraThinMaterial)
      }
      .if(!UIDevice.isVision) { view in
        view
          .background(capsuleColor)
      }
      .frame(width: segmentWidth(size), height: size.height - 6)
      .clipShape(Capsule())
      .offset(x: offsetX)
      .animation(.easeInOut(duration: 0.3), value: isList)
  }

  private var segmentedItemView: some View {
    HStack(spacing: 0) {
      listButton
      gridButton
    }
  }

  private var listButton: some View {
    Image(systemName: "rectangle.grid.1x2")
      .resizable()
      .frame(width: 16, height: 16)
      .foregroundStyle(isList ? accentColorType.color : .gray)
      .frame(width: segmentWidth(size))
      .scaleHoverEffect()
    .offset(x: 4)
    .onTapGesture {
      withAnimation(.easeInOut(duration: 0.5)) {
        isList = true
      }
    }
  }
  
  private var gridButton: some View {
    Image(systemName: Image.grid)
      .resizable()
      .frame(width: 16, height: 16)
      .foregroundStyle(!isList ? accentColorType.color : .gray)
      .frame(width: segmentWidth(size))
      .scaleHoverEffect()
    .offset(x: -4)
    .onTapGesture {
      withAnimation(.easeInOut(duration: 0.5)) {
        isList = false
      }
    }
  }

  private func segmentWidth(_ mainSize: CGSize) -> CGFloat {
    var width = (mainSize.width / 2)
    if width < 0 {
      width = 0
    }
    return width
  }

  private func calculateSegmentOffset(_ mainSize: CGSize) -> CGFloat {
    segmentWidth(mainSize) * (isList ? 0 : 1)
  }

}

#Preview {
  @Previewable @State var isList: Bool = false

  SwitchButton(
    isList: $isList,
    size: .init(width: 80, height: 34)
  )
}

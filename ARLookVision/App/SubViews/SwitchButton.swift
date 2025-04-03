//
//  SwitchButton.swift
//  ARLook
//
//  Created by Narek on 03.04.25.
//

import SwiftUI

struct SwitchButton: View {

  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue
  @AppStorage(CustomColorScheme.defaultKey) var customColorScheme = CustomColorScheme.defaultValue
  @Environment(\.colorScheme) var colorScheme
  @Binding var selection: DisplayMode

  private let size: CGSize

  private var offsetX: CGFloat {
    let isFirst = selection == DisplayMode.allCases.first
    let isLast = selection == DisplayMode.allCases.last
    let offset = calculateSegmentOffset(size)
    return isFirst ? offset + 4 : isLast ? offset - 4 : offset
  }

  private var isDarkMode: Bool {
    customColorScheme == .dark || customColorScheme == .system && colorScheme == .dark
  }

  private var capsuleColor: Color { isDarkMode ? .black : .white }

  private var isSmall: Bool { size.width < 320 }

  public init(selection: Binding<DisplayMode>, size: CGSize) {
    self._selection = selection
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
      .animation(.easeInOut(duration: 0.3), value: selection)
  }

  private var segmentedItemView: some View {
    HStack(spacing: 0) {
      ForEach(DisplayMode.allCases, id: \.self) { displayMode in
        segmentLabelView(
          displayMode: displayMode,
          textColor: selection == displayMode ? .white : .gray,
          width: segmentWidth(size)
        )
        .onTapGesture {
          selection = displayMode
        }
      }
    }
  }

  private func segmentLabelView(
    displayMode: DisplayMode,
    textColor: Color,
    width: CGFloat
  ) -> some View {
    HStack(spacing: 0) {
      displayMode.icon
        .renderingMode(.template)
        .resizable()
        .frame(width: 16, height: 16)
        .foregroundStyle(displayMode == selection ? .white : .gray)
        .offset(x: displayMode == DisplayMode.allCases.last ? -4 : 4)
    }
    .frame(width: width)
    .scaleHoverEffect()
  }

  private func segmentWidth(_ mainSize: CGSize) -> CGFloat {
    var width = (mainSize.width / CGFloat(DisplayMode.allCases.count))
    if width < 0 {
      width = 0
    }
    return width
  }

  private func calculateSegmentOffset(_ mainSize: CGSize) -> CGFloat {
    segmentWidth(mainSize) * CGFloat(selection.id)
  }

}

#Preview {
  @Previewable @State var selection: DisplayMode = .list

  SwitchButton(
    selection: $selection,
    size: .init(width: 700, height: 40)
  )
}

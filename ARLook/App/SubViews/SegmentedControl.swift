//
//  SegmentedControl.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import SwiftUI

struct SegmentedControl: View {

  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue
  @AppStorage(CustomColorScheme.defaultKey) var customColorScheme = CustomColorScheme.defaultValue
  @Environment(\.colorScheme) var colorScheme
  @Binding var selection: SearchScreen.ModelType

  private let size: CGSize

  private var offsetX: CGFloat {
    let isFirst = selection == SearchScreen.ModelType.allCases.first
    let isLast = selection == SearchScreen.ModelType.allCases.last
    let offset = calculateSegmentOffset(size)
    return isFirst ? offset + 4 : isLast ? offset - 4 : offset
  }

  private var iconOffsetX: CGFloat {
    let isFirst = selection == SearchScreen.ModelType.allCases.first
    let isLast = selection == SearchScreen.ModelType.allCases.last
    return isSmall ? (isFirst ? 4 : isLast ? -4 : 0) : 0
  }

  private var isDarkMode: Bool {
    customColorScheme == .dark || customColorScheme == .system && colorScheme == .dark
  }

  private var capsuleColor: Color { isDarkMode ? .black : .white }

  private var isSmall: Bool { size.width < 320 }

  public init(selection: Binding<SearchScreen.ModelType>, size: CGSize) {
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
      ForEach(SearchScreen.ModelType.allCases, id: \.self) { modelType in
        segmentLabelView(
          modelType: modelType,
          textColor: selection == modelType ? accentColorType.color : .gray,
          width: segmentWidth(size)
        )
        .onTapGesture {
          selection = modelType
        }
      }
    }
  }

  private func segmentLabelView(
    modelType: SearchScreen.ModelType,
    textColor: Color,
    width: CGFloat
  ) -> some View {
    HStack(spacing: 8) {
      if let icon = modelType.icon {
        icon
          .resizable()
          .frame(width: 16, height: 16)
          .foregroundStyle(textColor)
          .offset(x: modelType == .recent ? -4 : 0)
      }

      if modelType == .all || !isSmall {
        Text(modelType.name)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: false)
          .foregroundStyle(textColor)
          .offset(x: modelType == .all ? 4 : 0)
      }
    }
    .frame(width: width)
    .scaleHoverEffect()
  }

  private func segmentWidth(_ mainSize: CGSize) -> CGFloat {
    var width = (mainSize.width / CGFloat(SearchScreen.ModelType.allCases.count))
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
  @Previewable @State var selection: SearchScreen.ModelType = .all

  SegmentedControl(
    selection: $selection,
    size: .init(width: 300, height: 40)
  )
}

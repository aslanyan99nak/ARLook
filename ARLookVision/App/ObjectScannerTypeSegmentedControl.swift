//
//  ObjectScannerTypeSegmentedControl.swift
//  ARLook
//
//  Created by Narek on 19.03.25.
//

import SwiftUI

struct ObjectScannerTypeSegmentedControl: View {

  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue
  @AppStorage(CustomColorScheme.defaultKey) var customColorScheme = CustomColorScheme.defaultValue
  @Environment(\.colorScheme) var colorScheme
  @Binding var selection: ObjectScannerType

  private let size: CGSize

  private var offsetX: CGFloat {
    let isFirst = selection == ObjectScannerType.allCases.first
    let isLast = selection == ObjectScannerType.allCases.last
    let offset = calculateSegmentOffset(size)
    return isFirst ? offset + 4 : isLast ? offset - 4 : offset
  }

  private var isDarkMode: Bool {
    customColorScheme == .dark || customColorScheme == .system && colorScheme == .dark
  }

  private var capsuleColor: Color { isDarkMode ? .black : .white }
  private var isSmall: Bool { size.width < 320 }

  public init(selection: Binding<ObjectScannerType>, size: CGSize) {
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
      ForEach(ObjectScannerType.allCases, id: \.self) { modelType in
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
    modelType: ObjectScannerType,
    textColor: Color,
    width: CGFloat
  ) -> some View {
    HStack(spacing: 8) {
      Text(modelType.name)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: false)
        .foregroundStyle(textColor)
        .offset(x: modelType == ObjectScannerType.allCases.last ? -4 : 0)
    }
    .frame(width: width)
    .scaleHoverEffect()
  }

  private func segmentWidth(_ mainSize: CGSize) -> CGFloat {
    var width = (mainSize.width / CGFloat(ObjectScannerType.allCases.count))
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
  ObjectScannerTypeSegmentedControl(
    selection: .constant(.meshes),
    size: .init(width: 400, height: 80)
  )
}

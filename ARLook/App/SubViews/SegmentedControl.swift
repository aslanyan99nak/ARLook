//
//  SegmentedControl.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import SwiftUI

struct SegmentedControl: View {

  @Binding var selection: SearchScreen.ModelType

  private let size: CGSize
  
  private var offsetX: CGFloat {
    let isFirst = selection == SearchScreen.ModelType.allCases.first
    let isLast = selection == SearchScreen.ModelType.allCases.last
    let offset = calculateSegmentOffset(size)
    return isFirst ? offset + 4 : isLast ? offset - 4 : offset
  }
  
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
      .frame(width: size.width, height: size.height)
      .foregroundStyle(.gray)
      .opacity(0.2)
  }
  
  private var smallCapsuleView: some View {
    Capsule()
      .frame(width: segmentWidth(size), height: size.height - 6)
      .foregroundStyle(.black)
      .offset(x: offsetX)
      .animation(.easeInOut(duration: 0.3), value: selection)
  }
  
  private var segmentedItemView: some View {
    HStack(spacing: 0) {
      ForEach(SearchScreen.ModelType.allCases, id: \.self) { modelType in
        segmentLabelView(
          modelType: modelType,
          textColor: selection == modelType ? Color.blue : Color.white,
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
      }
      
      Text(modelType.name)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: false)
        .foregroundStyle(textColor)
    }
    .frame(width: width)
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

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
      Capsule()
        .frame(width: size.width, height: size.height)
        .foregroundColor(.gray)
        .opacity(0.2)

      Capsule()
        .frame(width: segmentWidth(size), height: size.height - 6)
        .foregroundColor(.black)
        .offset(x: offsetX)
        .animation(.easeInOut(duration: 0.3), value: selection)

      HStack(spacing: 0) {
        ForEach(SearchScreen.ModelType.allCases, id: \.self) { modelType in
          SegmentLabel(
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

fileprivate struct SegmentLabel: View {

  let modelType: SearchScreen.ModelType
  let textColor: Color
  let width: CGFloat

  var body: some View {
    HStack(spacing: 8) {
      if let icon = modelType.icon {
        icon
          .resizable()
          .frame(width: 16, height: 16)
          .foregroundColor(textColor)
      }
      
      Text(modelType.name)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: false)
        .foregroundColor(textColor)
    }
    .frame(width: width)
  }
  
}

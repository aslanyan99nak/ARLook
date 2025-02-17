//
//  ColorPicker.swift
//  ARLook
//
//  Created by Narek Aslanyan on 14.02.25.
//

import SwiftUI

struct ColorPicker: View {

  @State private var isColorSheetPresented = false
  @State private var brightness: CGFloat = 0
  @Binding var accentColorType: AccentColorType

  private let colors: [AccentColorType] = AccentColorType.allCases
  private let adaptiveColumn = [GridItem(.adaptive(minimum: 52))]

  var body: some View {
    colorButon
      .sheet(isPresented: $isColorSheetPresented) {
        NavigationStack {
          colorGridView
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Background Color")
        }
        .presentationDetents([.fraction(0.4)])
        .presentationCornerRadius(32)
        .presentationBackground {
          presentationBackground
        }
      }
  }

  private var colorButon: some View {
    Button {
      isColorSheetPresented = true
    } label: {
      Circle()
        .tint(accentColorType.color)
        .frame(width: 24, height: 24)
    }
  }

  private var colorGridView: some View {
    VStack {
      LazyVGrid(columns: adaptiveColumn, spacing: 20) {
        ForEach(colors, id: \.self) { item in
          CircleButton(
            item: item.color.adjust(
              brightness: item.color == accentColorType.color ? brightness : 0),
            isSelected: item == accentColorType
          ) {
            accentColorType = item
          }
        }
      }
    }
    .padding(.horizontal)
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        closeButton
      }
    }
  }

  private var closeButton: some View {
    Button {
      isColorSheetPresented = false
    } label: {
      Image(systemName: "xmark.circle.fill")
        .font(.system(size: 24))
        .fontDesign(.rounded)
        .symbolRenderingMode(.hierarchical)
        .foregroundStyle(.gray)
    }
  }

  private var presentationBackground: some View {
    ZStack {
      Color(uiColor: UIColor.secondarySystemBackground)
      LinearGradient(
        colors: [
          accentColorType.color.adjust(brightness: brightness).opacity(0.05),
          accentColorType.color.adjust(brightness: brightness).opacity(0.1),
          accentColorType.color.adjust(brightness: brightness).opacity(0.15),
          accentColorType.color.adjust(brightness: brightness).opacity(0.2),
        ],
        startPoint: .top,
        endPoint: .bottom
      )
    }
  }

}

#Preview {
  ColorPicker(accentColorType: .constant(.blue))
}

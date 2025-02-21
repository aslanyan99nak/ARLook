//
//  ModelItemView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 10.02.25.
//

import SwiftUI

struct ModelItemView: View {

  @Environment(\.colorScheme) private var colorScheme
//  @AppStorage(CustomColorScheme.defaultKey) var colorScheme = CustomColorScheme.defaultValue
  @Binding var isList: Bool

  let modelManager = ModelManager.shared
  let title: String
  var description: String = "Description Description"
  var viewCountString: String = "167K"

  private var isDarkMode: Bool {
    colorScheme == .dark
  }

  var body: some View {
    contentView
  }

  private var contentView: some View {
    modelContent
      .frame(height: isList ? 120 : 180)
      .padding(16)
      .background(.regularMaterial)
      .background(isDarkMode ? Color.gray.opacity(0.15) : Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 24))
      .shadow(radius: 10)
  }

  private var modelContent: some View {
    ZStack {
      if isList {
        contentViewForList
      } else {
        contentViewForGrid
      }
    }
  }

  private var contentViewForList: some View {
    HStack(alignment: .top, spacing: 16) {
      VStack(spacing: 0) {
        modelView
        Spacer()
        viewCount
      }

      VStack(alignment: .leading, spacing: 8) {
        modelNameView
        modelDescriptionView
      }
      .padding(.leading, 16)

      Spacer()
    }
  }

  private var contentViewForGrid: some View {
    HStack(spacing: 0) {
      Spacer()
      VStack(spacing: 0) {
        modelNameView
          .padding(.horizontal, 8)
        Spacer()
        modelView
        Spacer()
        viewCount
      }
      Spacer()
    }
  }

  @ViewBuilder
  private var modelView: some View {
    if let image = modelManager.thumbnail(
      for: "ClassicZombie.usdz",
      size: CGSize(width: 512, height: 512)
    ) {
      Image(uiImage: image)
        .resizable()
        .frame(width: 90, height: 90)
    }
  }

  private var viewCount: some View {
    HStack(spacing: 8) {
      Image(systemName: Image.eye)
        .renderingMode(.template)
        .resizable()
        .frame(width: 20, height: 12)
        .foregroundStyle(isDarkMode ? .white : .black)

      Text(viewCountString)
        .multilineTextAlignment(.leading)
        .dynamicFont()
        .foregroundStyle(isDarkMode ? .white : .black)
    }
  }

  private var modelNameView: some View {
    Text(title)
      .dynamicFont(size: isList ? 16 : 14, weight: .medium, design: .rounded)
      .lineLimit(3)
      .multilineTextAlignment(.leading)
      .foregroundStyle(isDarkMode ? .white : .black)
  }

  private var modelDescriptionView: some View {
    Text(description)
      .multilineTextAlignment(.leading)
      .dynamicFont(size: 14, weight: .regular, design: .rounded)
      .foregroundStyle(isDarkMode ? .white : .black)
  }

}

#Preview {
  @Previewable @State var isList: Bool = true

  ModelItemView(
    isList: $isList,
    title: "Model1"
  )
  .padding()
}

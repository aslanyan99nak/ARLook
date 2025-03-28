//
//  ModelItemView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 10.02.25.
//

import NukeUI
import SwiftUI

struct ModelItemView: View {

  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue
  @Environment(\.colorScheme) private var colorScheme
  @State private var loadedImage: UIImage?
  @State private var isLoading: Bool = false
  @Binding var isList: Bool

  let model: Model
  var favoriteAction: (() -> Void)?

  private let modelManager = ModelManager.shared
  private var title: String { model.name ?? "" }
  private var description: String { model.description ?? "" }
  private var isDarkMode: Bool { colorScheme == .dark }
  private var url: URL? { model.localFileURL }

  var body: some View {
    contentView
      .onLoad {
        loadModelImage()
      }
      .onChange(of: model) { oldValue, newValue in
        if oldValue.localFileURL != newValue.localFileURL {
          loadModelImage()
        }
      }
  }

  private var contentView: some View {
    modelContent
      .frame(height: isList ? 120 : 180)
      .padding(.horizontal, 16)
      .background(.regularMaterial)
      .background(isDarkMode ? Color.gray.opacity(0.15) : Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 24))
      .if(!isDarkMode) { view in
        view
          .shadow(color: .gray.opacity(0.4), radius: 2, x: 0, y: 2)
      }
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
    HStack(alignment: .top, spacing: 4) {
      modelView
      HStack(spacing: 8) {
        VStack(alignment: .leading, spacing: 8) {
          modelNameView
          modelDescriptionView
          Spacer()
          HStack(spacing: 0) {
            viewCount
            Spacer()
            modelFileSizeView
            Spacer()
          }
        }
        .padding(.leading, 16)

        if favoriteAction.isNotNil {
          VStack(alignment: .trailing, spacing: 0) {
            favoriteButton
            Spacer()
            Image(.arIcon)
          }
        }
      }
    }
    .frame(height: 90)
  }

  private var contentViewForGrid: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        modelView
        Spacer()
        VStack(alignment: .trailing, spacing: 0) {
          favoriteButton
          Spacer()
          Image(.arIcon)
            .resizable()
            .frame(width: 40, height: 40)
        }
      }
      .frame(height: 80)

      HStack(spacing: 0) {
        modelNameView
        Spacer()
      }
      .padding(.vertical, 8)
      HStack(spacing: 8) {
        viewCount
        Spacer()
        modelFileSizeView
      }
    }
  }

  private var modelFileSizeView: some View {
    Text(model.fileSizeString)
      .multilineTextAlignment(.leading)
      .dynamicFont()
      .foregroundStyle(isDarkMode ? .white : .black.opacity(0.3))
  }

  @MainActor
  private var modelView: some View {
    ZStack {
      if let thumbnailURL = model.thumbnailFileURL {
        LazyImage(url: thumbnailURL) { state in
          if let image = state.image {
            image
              .resizable()
              .clipShape(RoundedRectangle(cornerRadius: 12))
          } else {
            CircularProgressView(tintColor: accentColorType.color)
          }
        }
      } else if let loadedImage {
        Image(uiImage: loadedImage)
          .resizable()
      } else if isLoading {
        CircularProgressView(tintColor: accentColorType.color)
      }

      if model.isLoading, model.loadingProgress != 1 {
        ActivityProgressView(
          progress: Float(model.loadingProgress),
          color: accentColorType.color,
          scale: 0.4,
          isTextHidden: true
        )
      }
    }
    .frame(width: isList ? 90 : 80, height: isList ? 90 : 80)
  }

  private var viewCount: some View {
    HStack(spacing: 8) {
      Image(systemName: Image.eye)
        .renderingMode(.template)
        .resizable()
        .frame(width: 20, height: 12)
        .foregroundStyle(isDarkMode ? .white : .black.opacity(0.3))

      Text(model.viewCountString)
        .multilineTextAlignment(.leading)
        .dynamicFont()
        .foregroundStyle(isDarkMode ? .white : .black.opacity(0.3))
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
      .foregroundStyle(isDarkMode ? .white : .black.opacity(0.3))
  }

  private var favoriteButton: some View {
    Button {
      favoriteAction?()
    } label: {
      if model.isFavoriteLoading {
        CircularProgressView(tintColor: accentColorType.color)
      } else {
        Image(systemName: (model.isFavorite ?? false) ? "heart.fill" : "heart")
          .renderingMode(.template)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 20)
          .foregroundStyle(
            (model.isFavorite ?? false) ? accentColorType.color : isDarkMode ? .white : .black.opacity(0.3))
      }
    }
  }

  private func loadModelImage() {
    guard let url else { return }
    isLoading = true
    modelManager.thumbnail(
      for: url,
      size: CGSize(width: 512, height: 512)
    ) { image in
      isLoading = false
      self.loadedImage = image
    }
  }

}

#Preview {
  @Previewable @State var isList: Bool = true

  HStack(spacing: 0) {
    ModelItemView(
      isList: $isList,
      model: Model.mockModel
    ) {}
    .padding()
  }
}

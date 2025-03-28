//
//  ModelItemView.swift
//  ARLook
//
//  Created by Narek on 07.03.25.
//

import SwiftUI
import NukeUI

struct ModelItemView: View {

  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue
  @Environment(\.colorScheme) private var colorScheme
  @State private var loadedImage: UIImage?
  @State private var isLoading: Bool = false
  @Binding var isList: Bool

  let model: Model
  var favoriteAction: () -> Void

  private let modelManager = ModelManager.shared
  private var title: String { model.name ?? "" }
  private var description: String { model.description ?? "" }
  private var url: URL? { model.localFileURL }

  var body: some View {
    contentView
      .onAppear {
        loadModelImage()
      }
      .onChange(of: model) { oldValue, newValue in
        if oldValue != newValue {
          loadModelImage()
        }
      }
  }

  private var contentView: some View {
    modelContent
      .padding(16)
      .background(.regularMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 24))
  }

  private var modelContent: some View {
    VStack {
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
        HStack(spacing: 0) {
          modelNameView
          Spacer()
          favoriteButton
        }
        modelDescriptionView
        Text(model.fileSizeString)
          .multilineTextAlignment(.leading)
          .dynamicFont()
          .foregroundStyle(.white)
      }
      .padding(.leading, 16)

      Spacer()
    }
  }

  private var contentViewForGrid: some View {
    VStack(spacing: 8) {
      modelView
      HStack(spacing: 0) {
        modelNameView
        Spacer()
        favoriteButton
      }
      HStack(spacing: 0) {
        modelDescriptionView
        Spacer()
      }
      HStack(spacing: 0) {
        ownerView
        Spacer()
        viewCount

        Text(model.fileSizeString)
          .multilineTextAlignment(.leading)
          .dynamicFont()
          .foregroundStyle(.white)
          .padding(.leading, 8)
      }
    }
    .padding(.horizontal, 8)
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
    .frame(width: 90, height: 90)
  }

  private var viewCount: some View {
    HStack(spacing: 8) {
      Image(systemName: Image.eye)
        .renderingMode(.template)
        .resizable()
        .frame(width: 20, height: 12)
        .foregroundStyle(.white)

      Text(model.viewCountString)
        .multilineTextAlignment(.leading)
        .dynamicFont()
        .foregroundStyle(.white)
    }
    .padding(.horizontal, 8)
  }

  private var modelNameView: some View {
    Text(title)
      .dynamicFont(size: isList ? 16 : 14, weight: .medium, design: .rounded)
      .lineLimit(3)
      .multilineTextAlignment(.leading)
      .foregroundStyle(.white)
  }

  private var modelDescriptionView: some View {
    Text(description)
      .lineLimit(2)
      .multilineTextAlignment(.leading)
      .dynamicFont(size: 14, weight: .regular, design: .rounded)
      .foregroundStyle(.white)
  }

  private var ownerView: some View {
    Text("Owner")
      .multilineTextAlignment(.leading)
      .dynamicFont(size: 14, weight: .regular, design: .rounded)
      .foregroundStyle(.white)
  }

  private var favoriteButton: some View {
    Button {
      favoriteAction()
    } label: {
      if model.isFavoriteLoading {
        CircularProgressView(tintColor: accentColorType.color)
      } else {
        Image(systemName: (model.isFavorite ?? false) ? "heart.fill" : "heart")
          .renderingMode(.template)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 20)
          .foregroundStyle(accentColorType.color)
          .padding(10)
          .background(.regularMaterial)
          .scaleHoverEffect(scale: 1.2)
          .clipShape(Circle())
      }
    }
    .buttonStyle(.plain)
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
  @Previewable @State var isList: Bool = false

  ZStack {
    Color.red.ignoresSafeArea()
    ModelItemView(
      isList: $isList,
      model: Model.mockModel
    ) {}
    .padding()
  }
}

//
//  ModelItemView.swift
//  ARLook
//
//  Created by Narek on 07.03.25.
//

import NukeUI
import SwiftUI

struct ModelItemView: View {

  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue
  @Environment(\.colorScheme) private var colorScheme
  @State private var loadedImage: UIImage?
  @State private var isLoading: Bool = false
  @Binding var displayMode: DisplayMode

  let model: Model
  var favoriteAction: () -> Void

  private let modelManager = ModelManager.shared
  private var title: String { model.name ?? "" }
  private var description: String { model.description ?? "" }
  private var url: URL? { model.localFileURL }
  private var isList: Bool { displayMode == .list }

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
      .padding(10)
      .linearGradientBackground(
        shapeType: .roundedRectangle(cornerRadius: 26)
      )
      .if(!isList) { view in
        view
          .frame(width: 180)
          .overlay(alignment: .bottomTrailing) {
            favoriteButton
              .offset(x: 16, y: 16)
          }
      }
      .if(isList) { view in
        view
          .frame(height: 120)
      }
  }

  @ViewBuilder
  private var modelContent: some View {
    if isList {
      contentViewForList
    } else {
      contentViewForGrid
    }
  }

  private var contentViewForList: some View {
    HStack(alignment: .top, spacing: 16) {
      modelView

      VStack(alignment: .leading, spacing: 0) {
        modelNameView
          .padding(.bottom, 8)
        modelDescriptionView
          .padding(.bottom, 8)
        Spacer()
        HStack(spacing: 30) {
          viewCount
          fileSizeView
          Spacer()
        }
      }
      .padding(.leading, 16)
      .frame(height: 100)

      Spacer()

      Image(.arIcon)
        .renderingMode(.template)
        .resizable()
        .foregroundStyle(.gray)
        .frame(width: 100, height: 100)

      VStack(alignment: .trailing, spacing: 0) {
        favoriteButton
        Spacer()
      }
    }
  }

  private var contentViewForGrid: some View {
    VStack(alignment: .leading, spacing: 8) {
      modelView
      modelNameView
      modelDescriptionView
      HStack(spacing: 20) {
        viewCount
        fileSizeView
      }
    }
    .padding(.horizontal, 8)
  }

  private var fileSizeView: some View {
    Text(model.fileSizeString)
      .multilineTextAlignment(.leading)
      .dynamicFont()
      .foregroundStyle(.gray)
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
    .frame(
      width: isList ? 100 : 160,
      height: isList ? 100 : 160
    )
    .overlay(alignment: .topTrailing) {
      if !isList {
        Image(.arIcon)
          .renderingMode(.template)
          .resizable()
          .foregroundStyle(.gray)
          .frame(width: 30, height: 30)
          .padding(.top, 10)
          .padding(.trailing, 10)
      }
    }
  }

  private var viewCount: some View {
    HStack(spacing: 8) {
      Image(systemName: Image.eye)
        .renderingMode(.template)
        .resizable()
        .frame(width: 20, height: 12)
        .foregroundStyle(.gray)

      Text(model.viewCountString)
        .multilineTextAlignment(.leading)
        .dynamicFont()
        .foregroundStyle(.gray)
    }
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
      .dynamicFont(size: 10, weight: .regular, design: .rounded)
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
        Image(systemName: "heart")
          .renderingMode(.template)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 20)
          .foregroundStyle(.white)
          .padding(10)
          .if(model.isFavorite ?? false) { view in
            view
              .background(accentColorType.color)
          }
          .if(!(model.isFavorite ?? false)) { view in
            view
              .background(.ultraThinMaterial)
          }
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
  @Previewable @State var displayMode: DisplayMode = .list

  ZStack {
    ModelItemView(
      displayMode: $displayMode,
      model: Model.mockModel
    ) {}
    .padding()
    .frame(width: 600, height: 120)
  }
}

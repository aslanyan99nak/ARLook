//
//  ModelItemView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 10.02.25.
//

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
      .padding(16)
      .background(.regularMaterial)
      .background(isDarkMode ? Color.gray.opacity(0.15) : Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 24))
      .shadow(radius: 10)
      .overlay(alignment: .topTrailing) {
        if !isList {
          favoriteButton
            .padding(.top, 8)
            .padding(.trailing, 8)
        }
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
      VStack(spacing: 0) {
        modelView
        Spacer()
        viewCount
      }
//      .padding(.trailing, 8)

      VStack(alignment: .leading, spacing: 8) {
        HStack(spacing: 0) {
          modelNameView
          if favoriteAction.isNotNil {
            Spacer()
            favoriteButton
          }
        }
//        .background(Color.red)
        
        modelDescriptionView
        Text(model.fileSizeString)
          .multilineTextAlignment(.leading)
          .dynamicFont()
          .foregroundStyle(isDarkMode ? .white : .black)
      }
      .padding(.leading, 16)

//      Spacer()
    }
  }

  private var contentViewForGrid: some View {
    HStack(spacing: 0) {
      Spacer()
      VStack(spacing: 0) {
//        HStack(spacing: 0) {
////          modelNameView
////            .padding(.leading, 30)
//          Spacer()
//          favoriteButton
//        }
//        .padding(.horizontal, 8)
//        Spacer()
        modelView
          .padding(.top, 8)
          
//        Spacer()
//        HStack(spacing: 0) {
          modelNameView
//          Spacer()
//        }
          .padding(.vertical, 8)
          .padding(.horizontal, 8)
        HStack(spacing: 8) {
          viewCount

          Text(model.fileSizeString)
            .multilineTextAlignment(.leading)
            .dynamicFont()
            .foregroundStyle(isDarkMode ? .white : .black)
        }
      }
      Spacer()
    }
//    .overlay {
//      if favoriteAction.isNotNil {
//        VStack(spacing: 0) {
//          favoriteButton
//          Spacer()
//        }
////          .padding(.trailing, -8)
////          .padding(.top, -8)
//      }
//    }
  }

  @MainActor
  private var modelView: some View {
    ZStack {
      if let thumbnailURL = model.thumbnailFileURL {
        AsyncImage(url: thumbnailURL) { image in
          image
            .resizable()
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } placeholder: {
          CircularProgressView(tintColor: accentColorType.color)
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
        .foregroundStyle(isDarkMode ? .white : .black)

      Text(model.viewCountString)
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

  private var favoriteButton: some View {
    Button {
      favoriteAction?()
    } label: {
      if model.isLoading {
        CircularProgressView(tintColor: accentColorType.color)
      } else {
        Image(systemName: (model.isFavorite ?? false) ? "heart.fill" : "heart")
          .renderingMode(.template)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 20)
          .foregroundStyle(accentColorType.color)
          .padding(10)
          .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
          .background(.regularMaterial)
          .clipShape(Circle())
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
  @Previewable @State var isList: Bool = false

  ModelItemView(
    isList: $isList,
    model: Model.mockModel
  ) {}
    .frame(width: 150, height: 200)
  .padding()
}

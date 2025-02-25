//
//  ModelItemView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 10.02.25.
//

import SwiftUI

struct ModelItemView: View {

  @Environment(\.colorScheme) private var colorScheme
  @Binding var isList: Bool
  @State private var loadedImage: UIImage?

  let modelManager = ModelManager.shared
  let model: Model
  var viewCountString: String = "167K"

  private var title: String {
    model.name ?? ""
  }

  private var description: String {
    model.description ?? ""
  }

  private var isDarkMode: Bool {
    colorScheme == .dark
  }

  private var url: URL? {
    model.localFileURL
  }

  var body: some View {
    contentView
      .onAppear {
        if let url {
          modelManager.thumbnail(
            for: url,
            size: CGSize(width: 512, height: 512)
          ) { image in
            self.loadedImage = image
          }
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

  @MainActor
  private var modelView: some View {
    ZStack {
      if let loadedImage {
        Image(uiImage: loadedImage)
          .resizable()
      }
      
      if model.isLoading, model.loadingProgress != 1 {
        ActivityProgressView(
          progress: Float(model.loadingProgress),
          color: .blue,
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
    model: Model(
      id: nil,
      name: "Model Name",
      fileName: "File Name",
      fileType: "File Type",
      description: "File Description"
    )
  )
  .padding()
}

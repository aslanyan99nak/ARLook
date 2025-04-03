//
//  UploadModelScreen.swift
//  ARLook
//
//  Created by Narek on 05.03.25.
//

import SwiftUI

struct UploadModelScreen: View {

  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue
  @StateObject private var viewModel = UploadViewModel()

  private let modelManager: ModelManager = .shared

  var body: some View {
    contentView
      .sheet(isPresented: $viewModel.isShowModelPicker) {
        DocumentPicker { url in
          viewModel.selectedURL = url
        }
      }
      .sheet(isPresented: $viewModel.isShowImagePicker) {
        ImagePicker(
          image: $viewModel.image,
          isShowPicker: $viewModel.isShowImagePicker
        )
      }
      .onChange(of: viewModel.selectedURL) {
        oldValue,
        newValue in
        guard let url = newValue else { return }
        modelManager.thumbnail(
          for: url,
          size: CGSize(width: 512, height: 512)
        ) { image in
          viewModel.image = image
        }
      }
  }

  private var contentView: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        Text(LocString.uploadDescription)
          .font(.extraLargeTitle)

        Spacer()
      }
      .padding(40)

      ScrollView(.vertical, showsIndicators: false) {
        VStack(alignment: .leading, spacing: 16) {
          HStack(alignment: .top, spacing: 46) {
            showModelPickerButton
            VStack(alignment: .leading, spacing: 40) {
              modelNameTextField
              modelDescriptionTextView
            }
          }

          HStack(alignment: .top, spacing: 46) {
            modelThumbnailButton
            Text(
              """
              Select a cover image for your 3D model.
              This image will be displayed as a preview before loading the full 3D model.
              """
            )
            .font(.title)
            .padding(.top, 50)
          }
          uploadButton
        }
        .padding(40)
        .padding(.top, 20)
      }
    }
  }

  private var showModelPickerButton: some View {
    Image(.vision3DFile)
      .renderingMode(.template)
      .aspectRatio(contentMode: .fit)
      .foregroundStyle(.white)
      .padding(40)
      .frame(width: 180, height: 180)
      .scaleHoverEffect()
      .linearGradientBackground(
        shapeType: .roundedRectangle(cornerRadius: 36)
      )
      .onTapGesture {
        viewModel.isShowModelPicker = true
      }
  }

  private var modelNameTextField: some View {
    TextField(LocString.modelName, text: $viewModel.modelName)
      .padding()
      .frame(height: 60)
      .background(.ultraThickMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .overlay(textFieldBackgroundEffect)
  }

  private var modelDescriptionTextView: some View {
    TextField(LocString.modelDescription, text: $viewModel.modelDescription, axis: .vertical)
      .padding()
      .frame(minHeight: 80)
      .background(.ultraThickMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .overlay(textFieldBackgroundEffect)
  }

  private var modelThumbnailButton: some View {
    ZStack {
      if let image = viewModel.image {
        Image(uiImage: image)
          .resizable()
      } else {
        Image(.imagePlaceholder)
          .renderingMode(.template)
          .resizable()
          .foregroundStyle(.white)
      }
    }
    .padding(40)
    .frame(width: 180, height: 180)
    .scaleHoverEffect()
    .linearGradientBackground(
      shapeType: .roundedRectangle(cornerRadius: 36)
    )
    .onTapGesture {
      viewModel.isShowImagePicker = true
    }
  }

  private var uploadButton: some View {
    Button {
      Task {
        if let fileURL = viewModel.selectedURL {
          await viewModel.uploadFile(
            fileURL: fileURL,
            thumbnailImage: viewModel.image
          )
        }
      }
    } label: {
      uploadButtonContentView
    }
    .disabled(viewModel.isLoading)
    .buttonStyle(PlainButtonStyle())
  }

  private var uploadButtonContentView: some View {
    HStack(spacing: 0) {
      Spacer()
      Text(LocString.upload)
        .foregroundStyle(.white)
        .dynamicFont(size: 20, weight: .medium)

      if viewModel.isLoading, viewModel.loadingProgress != 1 {
        ActivityProgressView(
          progress: Float(viewModel.loadingProgress),
          color: .white,
          scale: 0.1,
          isTextHidden: true
        )
        .padding(.leading, 16)
      } else {
        Image(.upload)
          .renderingMode(.template)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundStyle(.white)
          .frame(height: 24)
          .padding(.leading, 16)
      }

      Spacer()
    }
    .padding()
    .frame(height: 80)
    .background(accentColorType.color)
    .clipShape(Capsule())
  }

  private var textFieldBackgroundEffect: some View {
    RoundedRectangle(cornerRadius: 10)
      .stroke(Color.black, lineWidth: 1)
      .blur(radius: 1)
      .offset(x: 1, y: 1)
      .mask(
        RoundedRectangle(cornerRadius: 10)
          .fill(
            LinearGradient(
              colors: [Color.black, Color.clear], startPoint: .top, endPoint: .bottom))
      )
      .overlay {
        RoundedRectangle(cornerRadius: 10)
          .stroke(Color.white.opacity(0.7), lineWidth: 0.5)
          .mask(
            RoundedRectangle(cornerRadius: 10)
              .fill(
                LinearGradient(
                  colors: [Color.white, Color.clear], startPoint: .bottom, endPoint: .top))
          )
      }
  }

}

#Preview(windowStyle: .automatic) {
  UploadModelScreen()
}

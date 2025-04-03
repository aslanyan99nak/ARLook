//
//  UploadModelScreen.swift
//  ARLook
//
//  Created by Narek on 25.02.25.
//

import SwiftUI

struct UploadModelScreen: View {

  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue
  @StateObject private var viewModel = UploadViewModel()
  var url: URL?

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
      .onChange(of: viewModel.selectedURL) { oldValue, newValue in
        if newValue.isNotNil {
          if let url = newValue {
            modelManager.thumbnail(
              for: url,
              size: CGSize(width: 512, height: 512)
            ) { image in
              viewModel.image = image
            }
          }
        }
      }
  }

  private var contentView: some View {
    ScrollView(.vertical, showsIndicators: false) {
      Image(.uploadModelBar)
        .resizable()
      VStack(spacing: 0) {
        showModelPickerButton
        HStack(alignment: .center, spacing: 16) {
          modelThumbnail
          modelNameTextField
        }
        .padding(.bottom, 16)
        modelDescriptionTextView
          .padding(.bottom, 16)
        uploadButton
          .padding(.bottom, 16)
        Spacer()
      }
      .padding(.horizontal, 16)
    }
    .onLoad {
      if let url {
        viewModel.selectedURL = url
      }
    }
  }

  private var showModelPickerButton: some View {
    Button {
      viewModel.isShowModelPicker = true
    } label: {
      Image(.import3DModelButton)
    }
  }

  private var modelNameTextField: some View {
    TextField(LocString.modelName, text: $viewModel.modelName)
      .padding()
      .frame(height: 50)
      .background(
        RoundedRectangle(cornerRadius: 24)
          .stroke(Color.gray, lineWidth: 1)
      )
  }

  private var modelDescriptionTextView: some View {
    TextField(LocString.modelDescription, text: $viewModel.modelDescription, axis: .vertical)
      .padding()
      .frame(minHeight: 60)
      .background(
        RoundedRectangle(cornerRadius: 24)
          .stroke(Color.gray, lineWidth: 1)
      )
  }

  @ViewBuilder
  private var modelThumbnail: some View {
    ZStack {
      if let image = viewModel.image {
        Image(uiImage: image)
          .resizable()
      } else {
        Image(.imagePlaceholder)
          .renderingMode(.template)
          .resizable()
          .foregroundStyle(accentColorType.color)
          .padding(4)
          .background(
            RoundedRectangle(cornerRadius: 20)
              .stroke(Color.gray, lineWidth: 1)
              .padding(2)
          )
      }
    }
    .frame(width: 80, height: 80)
    .clipShape(RoundedRectangle(cornerRadius: 24))
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
      uploadButtonContent
    }
    .disabled(viewModel.isLoading)
  }

  private var uploadButtonContent: some View {
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
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 16)
          .padding(.leading, 16)
          .foregroundStyle(.white)
      }

      Spacer()
    }
    .padding()
    .background(accentColorType.color)
    .clipShape(Capsule())
  }

}

#Preview {
  UploadModelScreen()
}

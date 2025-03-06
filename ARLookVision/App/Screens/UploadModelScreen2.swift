//
//  UploadModelScreen2.swift
//  ARLook
//
//  Created by Narek on 05.03.25.
//

import SwiftUI

struct UploadModelScreen2: View {

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

  private var contentView: some View {
    VStack(spacing: 0) {
      Text(LocString.uploadDescription)
        .font(.extraLargeTitle)
        .padding(20)
      ScrollView(.vertical, showsIndicators: false) {
        VStack(alignment: .leading, spacing: 16) {
          HStack(alignment: .top, spacing: 16) {
            showModelPickerButton
            VStack(alignment: .leading, spacing: 40) {
              modelNameTextField
              modelDescriptionTextView
            }
            .padding(.top, 50)
          }

          HStack(alignment: .top, spacing: 16) {
            modelThumbnail
            Text(
              "Select a cover image for your 3D model. This image will be displayed as a preview before loading the full 3D model."
            )
            .font(.title)
            .padding(.top, 50)
          }
          uploadButton
        }
        .padding(20)
        .padding(.top, 20)
      }
    }
  }

  private var showModelPickerButton: some View {
    Button {
      viewModel.isShowModelPicker = true
    } label: {
      Image(._3Dm)
        .renderingMode(.template)
        .resizable()
        .frame(width: 150, height: 150)
        .foregroundStyle(accentColorType.color)
        .padding(40)
    }
    .buttonStyle(PlainButtonStyle())
  }

  private var modelNameTextField: some View {
    TextField(LocString.modelName, text: $viewModel.modelName)
      .padding()
      .frame(height: 50)
      .background(
        RoundedRectangle(cornerRadius: 24)
          .stroke(Color.white, lineWidth: 1)
      )
  }

  private var modelDescriptionTextView: some View {
    TextField(LocString.modelDescription, text: $viewModel.modelDescription, axis: .vertical)
      .padding()
      .frame(minHeight: 80)
      .background(
        RoundedRectangle(cornerRadius: 24)
          .stroke(Color.white, lineWidth: 1)
      )
  }

  private var modelThumbnail: some View {
    Button {
      viewModel.isShowImagePicker = true
    } label: {
      ZStack {
        if let image = viewModel.image {
          Image(uiImage: image)
            .resizable()
        } else {
          Image(systemName: Image.photo)
            .renderingMode(.template)
            .resizable()
            .foregroundStyle(accentColorType.color)
        }
      }
      .frame(width: 150, height: 150)
      .padding(40)
    }
    .buttonStyle(PlainButtonStyle())
  }

  private var uploadButton: some View {
    Button {
      Task {
        if let fileURL = viewModel.selectedURL {
          await viewModel.uploadFile(fileURL: fileURL)
        }
      }
    } label: {
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
          Image(systemName: Image.upload)
            .resizable()
            .frame(height: 24)
            .aspectRatio(contentMode: .fit)
            .padding(.leading, 16)
        }

        Spacer()
      }
      .padding()
      .background(accentColorType.color)
      .clipShape(Capsule())
    }
    .disabled(viewModel.isLoading)
    .buttonStyle(PlainButtonStyle())
  }

}

#Preview(windowStyle: .automatic) {
  UploadModelScreen2()
}

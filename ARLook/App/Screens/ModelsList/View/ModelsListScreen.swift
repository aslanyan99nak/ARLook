//
//  ModelsListScreen.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import SwiftUI

struct ModelsListScreen: View {

  @AppStorage(CustomColorScheme.defaultKey) var colorScheme = CustomColorScheme.defaultValue
  @StateObject var viewModel = ModelsListViewModel()

  private var columns: [GridItem] {
    viewModel.isList ? [GridItem(.flexible())] : [GridItem(.flexible()), GridItem(.flexible())]
  }
  
  private var isDarkMode: Bool {
    colorScheme == .dark
  }

  var body: some View {
    NavigationStack {
      ZStack {
        VStack(spacing: 0) {
          navigationBar
          gridView
        }
      }
      .toolbar(.hidden, for: .navigationBar)
      .onLoad {
        Task {
          await viewModel.getModels()
        }
      }
    }
  }

  private var navigationBar: some View {
    VStack(spacing: 8) {
      HStack(spacing: 0) {
        Spacer()

        Text(LocString.existingModels)
          .offset(x: 40)

        Spacer()

        SwitchButton(isList: $viewModel.isList)
          .frame(width: 80, height: 30)
      }
      .padding(.horizontal, 16)

      Divider()
    }
  }

  private var gridView: some View {
    ScrollView(showsIndicators: false) {
      LazyVGrid(columns: columns, spacing: 20) {
        let files = viewModel.modelManager.loadFiles()
        ForEach(files, id: \.self) { modelName in
          Button {
            viewModel.selectedModelName = modelName
            if let selectedModelName = viewModel.selectedModelName {
              viewModel.modelManager.checkFileExists(fileName: selectedModelName) { isExists, url in
                if let url, isExists {
                  viewModel.previewURL = url
                }
              }
            }
          } label: {
            let model = Model(
              id: nil,
              name: modelName,
              fileName: nil,
              fileType: nil,
              description: nil
            )
            
            ModelItemView(
              isList: $viewModel.isList,
              model: model
            )
          }
          .quickLookPreview($viewModel.previewURL)
        }
      }
      .padding(.bottom, 40)
      .padding(.top, 20)
      .padding(.horizontal, 16)
    }
    .refreshable {
      Task {
        await viewModel.getModels()
      }
    }
  }

}

#Preview {
  ModelsListScreen()
}

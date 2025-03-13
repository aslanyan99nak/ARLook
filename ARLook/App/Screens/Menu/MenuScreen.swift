//
//  MenuScreen.swift
//  ARLook
//
//  Created by Narek on 25.02.25.
//

import SwiftUI

struct MenuScreen: View {

  @StateObject private var viewModel = SearchViewModel()
  @Binding var isShowPicker: Bool
  @Binding var fileURL: URL?
  @Binding var selectedModel: Model?

  private var columns: [GridItem] {
    viewModel.isList ? [GridItem(.flexible())] : [GridItem(.flexible()), GridItem(.flexible())]
  }

  var body: some View {
    NavigationStack {
      contentView
        .navigationTitle(LocString.search3D)
        .navigationBarTitleDisplayMode(.inline)
    }
    .searchable(text: $viewModel.searchText)
  }

  private var contentView: some View {
    ZStack {
      VStack(spacing: 0) {
        segmentedControlView
          .padding(.bottom, 8)
          .padding(.horizontal, 16)

        Divider()

        gridView
      }
    }
    .onLoad {
      Task {
        await viewModel.getModels()
      }
    }
  }

  private var gridView: some View {
    ScrollView(showsIndicators: false) {
      LazyVGrid(columns: columns, spacing: 20) {
        ForEach(viewModel.searchResults, id: \.self) { model in
          Button {
            viewModel.selectedModelName = model.name
            if model.localFileURL.isNotNil {
              fileURL = model.localFileURL
              isShowPicker = false
              selectedModel = model
            } else {
              if let id = model.id {
                Task {
                  await viewModel.downloadModel(
                    by: model.mainFilePath ?? "",
                    id: String(id)
                  )
                }
              }
            }
          } label: {
            ModelItemView(
              isList: $viewModel.isList,
              model: model
            )
          }
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

  private var segmentedControlView: some View {
    GeometryReader { geo in
      VStack(spacing: 0) {
        HStack(spacing: 0) {
          SegmentedControl(
            selection: $viewModel.selectedModelType,
            size: .init(width: geo.size.width - 96, height: 40)
          )
          .padding(.trailing, 16)

          SwitchButton(isList: $viewModel.isList)
            .frame(width: 80, height: 34)
        }
      }
    }
    .frame(height: 40)
  }

  private func deleteDownloadedModel(_ model: Model) {
    if let id = model.id, model.localFileURL.isNotNil {
      viewModel.deleteDownloadedModel(by: id)
    }
  }

  private func updateDownloadedModel(_ model: Model) {
    if let id = model.id, model.localFileURL.isNotNil {
      Task {
        await viewModel.downloadModel(
          by: model.mainFilePath ?? "",
          id: String(id)
        )
      }
    }
  }

}

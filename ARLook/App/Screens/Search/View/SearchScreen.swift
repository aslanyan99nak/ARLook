//
//  SearchScreen.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import QuickLook
import SwiftUI

extension SearchScreen {

  enum ModelType: String, CaseIterable {

    case recent
    case favorite
    case all

    var name: String {
      switch self {
      case .recent: LocString.recent
      case .favorite: LocString.favorite
      case .all: LocString.all
      }
    }

    var icon: Image? {
      switch self {
      case .recent: Image(systemName: Image.recent)
      case .favorite: Image(systemName: Image.favorite)
      case .all: nil
      }
    }

    var id: Int {
      switch self {
      case .recent: 0
      case .favorite: 1
      case .all: 2
      }
    }

  }

}

struct SearchScreen: View {

  @StateObject var viewModel = SearchViewModel()

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
              viewModel.previewURL = model.localFileURL
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
          .quickLookPreview($viewModel.previewURL)
          .onChange(of: viewModel.previewURL) { oldValue, newValue in
            if oldValue.isNotNil && newValue.isNil {
              Task {
                await viewModel.incrementViewsCount(by: String(model.id ?? 0))
              }
            }
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
    guard let id = model.id, model.localFileURL.isNotNil else { return }
    viewModel.deleteDownloadedModel(by: id)
  }

  private func updateDownloadedModel(_ model: Model) {
    guard let id = model.id, model.localFileURL.isNotNil else { return }
    Task {
      await viewModel.downloadModel(
        by: model.mainFilePath ?? "",
        id: String(id)
      )
    }
  }

}

#Preview {
  SearchScreen()
}

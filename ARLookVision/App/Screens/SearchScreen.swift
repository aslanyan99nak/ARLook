//
//  SearchScreen.swift
//  ARLook
//
//  Created by Narek on 05.03.25.
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

  @EnvironmentObject var lookAroundViewModel: LookAroundImmersiveViewModel
  @StateObject var viewModel = SearchViewModel()

  var isInImmersive: Bool = false

  private var columns: [GridItem] {
    viewModel.isList
      ? [GridItem(.flexible(), spacing: 40), GridItem(.flexible(), spacing: 40)]
      : [GridItem(.flexible()), GridItem(.flexible())]
  }

  var body: some View {
    NavigationStack {
      contentView
        .navigationTitle(LocString.search3D)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .bottomOrnament) {
            segmentedControlView
          }
        }
    }
    .searchable(text: $viewModel.searchText)
  }

  private var contentView: some View {
    gridView
      .onLoad {
        Task {
          await viewModel.getModels()
        }
      }
  }

  private var gridView: some View {
    GeometryReader { geometry in
      let flexibleColumns = Array(
        repeating: GridItem(.flexible(), spacing: 40),
        count: max(Int(geometry.size.width / 300), 1)
      )

      let columns = viewModel.isList ? self.columns : flexibleColumns
      ScrollView(showsIndicators: false) {
        LazyVGrid(columns: columns, spacing: 40) {
          ForEach(viewModel.searchResults, id: \.self) { model in
            makeModelContentView(model)
          }
        }
        .padding(.bottom, 40)
        .padding(.top, 20)
        .padding(.horizontal, 40)
      }
      .refreshable {
        Task {
          await viewModel.getModels()
        }
      }
    }
  }

  private func makeModelContentView(_ model: Model) -> some View {
    ModelItemView(
      isList: $viewModel.isList,
      model: model
    ) {
      if !model.isFavoriteLoading {
        Task {
          await viewModel.makeFavorite(by: String(model.id ?? 0))
        }
      }
    }
    .scaleHoverEffect(scale: viewModel.isList ? 1.1 : 1.2)
    .quickLookPreview($viewModel.previewURL)
    .onTapGesture {
      modelItemTapAction(model)
    }
    .onChange(of: viewModel.previewURL) { oldValue, newValue in
      if oldValue.isNotNil && newValue.isNil {
        Task {
          await viewModel.incrementViewsCount(by: String(model.id ?? 0))
        }
      }
    }
  }

  private var segmentedControlView: some View {
    HStack(spacing: 0) {
      SegmentedControl(
        selection: $viewModel.selectedModelType,
        size: .init(width: 400, height: 40)
      )
      .background(.ultraThickMaterial)
      .clipShape(Capsule())

      SwitchButton(
        isList: $viewModel.isList,
        size: .init(width: 120, height: 40)
      )
      .background(.ultraThickMaterial)
      .clipShape(Capsule())
      .padding(.horizontal, 16)
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

  private func modelItemTapAction(_ model: Model) {
    viewModel.selectedModelName = model.name
    if model.localFileURL.isNotNil {
      if isInImmersive {
        lookAroundViewModel.selectedFileURL = model.localFileURL
        lookAroundViewModel.selectedModel = model
      } else {
        viewModel.previewURL = model.localFileURL
      }
    } else {
      guard let id = model.id else { return }
      Task {
        await viewModel.downloadModel(
          by: model.mainFilePath ?? "",
          id: String(id)
        )
      }
    }
  }

}

#Preview {
  SearchScreen()
}

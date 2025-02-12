//
//  SearchScreen.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import SwiftUI

extension SearchScreen {

  enum ModelType: String, CaseIterable {

    case recent
    case favorite
    case all

    var name: String {
      switch self {
      case .recent: String.LocString.recent
      case .favorite: String.LocString.favorite
      case .all: String.LocString.all
      }
    }

    var icon: Image? {
      switch self {
      case .recent: Image(systemName: "memories")
      case .favorite: Image(systemName: "heart")
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

  @Environment(\.colorScheme) var colorScheme
  @StateObject var viewModel = SearchViewModel()
  
  var columns: [GridItem] {
    viewModel.isList ? [GridItem(.flexible())] : [GridItem(.flexible()), GridItem(.flexible())]
  }

  var body: some View {
    NavigationStack {
      contentView
        .navigationTitle(String.LocString.search3D)
        .navigationBarTitleDisplayMode(.inline)
    }
    .searchable(text: $viewModel.searchText)
  }

  private var contentView: some View {
    VStack(spacing: 0) {
      segmentedControlView
        .padding(.bottom, 8)
        .padding(.horizontal, 16)

      gridView
    }
  }

  private var gridView: some View {
    ScrollView(showsIndicators: false) {
      LazyVGrid(columns: columns, spacing: 20) {
        ForEach(viewModel.searchResults, id: \.self) { modelName in
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
            ModelItemView(isList: $viewModel.isList, title: modelName)
          }
          .quickLookPreview($viewModel.previewURL)
        }
      }
      .padding(.bottom, 40)
      .padding(.top, 40)
      .padding(.horizontal, 16)
    }
  }

  private var segmentedControlView: some View {
    GeometryReader { geo in
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
    .frame(height: 40)
  }

}

#Preview {
  SearchScreen()
}

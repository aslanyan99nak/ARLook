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
  @AppStorage(CustomColorScheme.defaultKey) var colorScheme = CustomColorScheme.defaultValue

  private var columns: [GridItem] {
    viewModel.isList ? [GridItem(.flexible())] : [GridItem(.flexible()), GridItem(.flexible())]
  }
  
  private var isDarkMode: Bool {
    colorScheme == .dark
  }

  var body: some View {
    NavigationStack {
      contentView
        .navigationTitle(LocString.search3D)
        .navigationBarTitleDisplayMode(.inline)
    }
    .searchable(text: $viewModel.searchText)
    .background(Color.red)
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
      .padding(.top, 20)
      .padding(.horizontal, 16)
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

}

#Preview {
  SearchScreen()
}

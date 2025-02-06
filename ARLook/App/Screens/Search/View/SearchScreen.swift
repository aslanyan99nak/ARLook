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
      case .recent: "Recent"
      case .favorite: "Favorite"
      case .all: "All"
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

  @State private var searchText = ""
  @State private var selectedModelType = ModelType.all

  private let names = ["Holly", "Josh", "Rhonda", "Ted"]
  
  private var searchResults: [String] {
    if searchText.isEmpty {
      return names
    } else {
      return names.filter { $0.contains(searchText) }
    }
  }

  var body: some View {
    NavigationStack {
      contentView
      .navigationTitle("Search 3D")
    }
    .searchable(text: $searchText)
  }
  
  private var contentView: some View {
    VStack(spacing: 0) {
      segmentedControlView
        .padding(.bottom, 8)
        .padding(.horizontal, 16)

      listView
    }
  }
  
  // TODO: - Change it using LazyGrid

  private var listView: some View {
    List {
      ForEach(searchResults, id: \.self) { name in
        NavigationLink {
          Text(name)
        } label: {
          Text(name)
        }
      }
    }
  }

  private var segmentedControlView: some View {
    GeometryReader { geo in
      SegmentedControl(
        selection: $selectedModelType,
        size: .init(width: geo.size.width, height: 40)
      )
    }
    .frame(height: 40)
  }

}

#Preview {
  SearchScreen()
}


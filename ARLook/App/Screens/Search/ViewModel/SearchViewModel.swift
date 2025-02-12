//
//  SearchViewModel.swift
//  ARLook
//
//  Created by Narek Aslanyan on 11.02.25.
//

import SwiftUI

class SearchViewModel: ObservableObject {
  
  @Published var searchText = ""
  @Published var selectedModelType = SearchScreen.ModelType.all
  @Published var isList: Bool = true
  @Published var previewURL: URL? = nil
  @Published var selectedURL: URL?
  @Published var selectedModelName: String?
  
  let modelManager = ModelManager.shared
  
  var searchResults: [String] {
    if searchText.isEmpty {
      modelManager.loadFiles()
    } else {
      modelManager.loadFiles().filter { $0.lowercased().contains(searchText.lowercased()) }
    }
  }
  
}

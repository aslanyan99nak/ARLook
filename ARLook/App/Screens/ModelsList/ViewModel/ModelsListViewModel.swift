//
//  ModelsListViewModel.swift
//  ARLook
//
//  Created by Narek Aslanyan on 11.02.25.
//

import SwiftUI

class ModelsListViewModel: ObservableObject {
  
  @Published var selectedModelType = SearchScreen.ModelType.all
  @Published var isList: Bool = true
  @Published var previewURL: URL? = nil
  @Published var selectedURL: URL?
  @Published var selectedModelName: String?
  
  let modelManager = ModelManager.shared
  
}

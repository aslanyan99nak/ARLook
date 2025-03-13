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
  @Published var models: [Model] = []
  
  let modelManager = ModelManager.shared
  private let modelEnvironment: Provider = Provider<ModelEndpoint>()
  
  @MainActor
  func getModels() async {
    do {
      let models: [Model] = try await modelEnvironment.request(.getList)
      self.models = models
      models.forEach { print("File name 📁: \($0.mainFileName ?? "Not found")") }
    } catch {
      print("Can't get models")
    }
  }
  
}

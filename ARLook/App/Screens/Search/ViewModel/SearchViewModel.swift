//
//  SearchViewModel.swift
//  ARLook
//
//  Created by Narek Aslanyan on 11.02.25.
//

import Foundation
import Moya
import SwiftUI

class SearchViewModel: ObservableObject {

  @Published var searchText = ""
  @Published var selectedModelType = SearchScreen.ModelType.all
  @Published var isList: Bool = true
  @Published var previewURL: URL? = nil
  @Published var selectedURL: URL?
  @Published var selectedModelName: String?
  @Published var models: [Model] = []

  let modelManager = ModelManager.shared
  private let modelEnvironment: Provider = Provider<ModelEndpoint>()

  var searchResults: [Model] {
    if searchText.isEmpty {
      models
    } else {
      models.filter { ($0.name ?? "").lowercased().contains(searchText.lowercased()) }
    }
  }

  @MainActor
  func getModels() async {
    do {
      let models: [Model] = try await modelEnvironment.request(.getList)
      self.models = models
      models.forEach { print("File name 📁: \($0.fileName ?? "Not found")") }
    } catch {
      print("Can't get models")
    }
  }

  @MainActor
  func downloadModel(by id: Int) async {
    guard let modelIndex = models.firstIndex(where: { $0.id == id }) else { return }
    models[modelIndex].isLoading = true
    do {
      let stream = try await modelEnvironment.downloadRequest(.download(id: String(id)))
      do {
        for try await progress in stream {
          let isCompleted = progress.completed
          print("Downloading Progress... \(progress.progress), isCompleted: \(isCompleted)")
          models[modelIndex].loadingProgress = progress.progress
          if isCompleted {
            models[modelIndex].isLoading = false
          }
        }
      } catch {
        models[modelIndex].isLoading = false
        print("❌Couldn't download pdf book with Error: \(error.localizedDescription)")
      }
    } catch {
      models[modelIndex].isLoading = false
      print("Can't get models")
    }
  }

  func deleteDownloadedModel(by id: Int) {
    modelManager.deleteFile(by: "\(id).usdz") { successed, url in
      if successed, let url {
        print("Delete \(id) model Successed: ✅ \(url.absoluteString)")
      }
    }
  }

}

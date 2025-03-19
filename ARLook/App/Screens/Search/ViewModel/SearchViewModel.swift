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
      selectedModelType == .all ? models : models.filter { $0.isFavorite ?? false }
    } else {
      models.filter { ($0.name ?? "").lowercased().contains(searchText.lowercased()) }
    }
  }

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

  @MainActor
  func downloadModel(by path: String, id: String) async {
    guard let modelIndex = models.firstIndex(where: { $0.mainFilePath == path }),
          let path = path.trimmedVersion
    else { return }
    
    models[modelIndex].isLoading = true
    do {
      let stream = try await modelEnvironment.downloadRequest(.download(path: path, id: id))
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
  
  @MainActor
  func incrementViewsCount(by id: String) async {
    do {
      let _: EmptyModel = try await modelEnvironment.request(.addViewCount(id: id))
      guard let modelIndex = models.firstIndex(where: { String($0.id ?? 0) == id }),
            let _ = models[modelIndex].viewsCount
      else { return }
      models[modelIndex].viewsCount! += 1
    } catch {
      print("❌ Can't Increment viewsCount: \(error.localizedDescription)")
    }
  }
  
  @MainActor
  func makeFavorite(by id: String) async {
    guard let modelIndex = models.firstIndex(where: { String($0.id ?? 0) == id }),
          let isFavorite = models[modelIndex].isFavorite
    else { return }
    do {
      models[modelIndex].isFavoriteLoading = true
      let _: EmptyModel = try await modelEnvironment.request(.favorite(id: id))
      models[modelIndex].isFavorite = !isFavorite
      models[modelIndex].isFavoriteLoading = false
    } catch {
      models[modelIndex].isFavoriteLoading = false
      print("❌ Can't Change model favorite: \(error.localizedDescription)")
    }
    
  }

}

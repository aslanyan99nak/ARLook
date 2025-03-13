//
//  UploadViewModel.swift
//  ARLook
//
//  Created by Narek on 25.02.25.
//

import SwiftUI

class UploadViewModel: ObservableObject {
  
  @Published var modelName: String = ""
  @Published var modelDescription: String = ""
  @Published var isShowModelPicker: Bool = false
  @Published var isShowImagePicker: Bool = false
  @Published var selectedURL: URL?
  @Published var image: UIImage?
  @Published var isLoading: Bool = false
  @Published var loadingProgress: CGFloat = 0

  let modelManager: ModelManager = .shared
  private let modelEnvironment: Provider = Provider<ModelEndpoint>()
  
  @MainActor
  func uploadFile(fileURL: URL, thumbnailImage: UIImage?) async {
    guard let fileData = try? Data(contentsOf: fileURL) else { return }
    var thumbnailFileData: Data?
    
    if let thumbnailImage {
      thumbnailFileData = thumbnailImage.jpegData(compressionQuality: 0.8)
    }
    
    let data = UploadDataModel(
      file: fileData,
      thumbnailFile: thumbnailFileData,
      name: modelName,
      description: modelDescription,
      filetype: "3dModel"
    )

    isLoading = true
    modelEnvironment.request(
      .upload(data: data),
      progress: { [weak self] progress in
        print("Upload Progress: \(progress.progress * 100)%")
        self?.loadingProgress = progress.progress
        if progress.completed {
          print("Progress complete ✅")
        }
      }
    ) { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(let response):
        selectedURL = nil
        image = nil
        modelName = ""
        modelDescription = ""
        loadingProgress = 0
        print("✅ Upload Success: \(response.statusCode)")
      case .failure(let error):
        print("❌ Upload Failed: \(error.localizedDescription)")
      }
      isLoading = false
    }

  }
  
}

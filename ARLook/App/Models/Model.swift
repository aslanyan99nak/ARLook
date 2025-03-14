//
//  Model.swift
//  ARLook
//
//  Created by Narek on 17.02.25.
//

import Foundation

struct Model: Codable, Hashable, Identifiable {

  let id: Int?
  let name: String?
  let mainFileName: String?
  let mainFileSize: Int64?
  let mainFilePath: String?
  let thumbnailFileName: String?
  let thumbnailFileSize: Int64?
  let thumbnailFilePath: String?
  var viewsCount: Int64?
  let isFavorite: Bool?
  let fileType: String?
  let description: String?

  var isLoading: Bool = false
  var loadingProgress: CGFloat = 0
  
  var viewCountString: String {
    (viewsCount ?? 0).formattedViewCount
  }
  
  var fileSizeString: String {
    (mainFileSize ?? 0).fileSizeFormatted
  }

  var localFileURL: URL? {
    guard let id else { return nil }
    let fileManager = FileManager.default
    guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    else { return nil }
    let fileURL = documentsDirectory.appendingPathComponent("\(id).usdz")
    return fileManager.fileExists(atPath: fileURL.path()) ? fileURL : nil
  }
  
  var thumbnailFileURL: URL? {
    guard let thumbnailFilePath else { return nil }
    let urlString = AppController.shared.environment.baseURL + thumbnailFilePath
    return URL(string: urlString)
  }

  enum CodingKeys: String, CodingKey {

    case id
    case name
    case mainFileName = "mailFileName"
    case mainFileSize = "mailFileSize"
    case mainFilePath
    case thumbnailFileName
    case thumbnailFileSize
    case thumbnailFilePath
    case viewsCount
    case isFavorite
    case fileType
    case description

  }

}

extension Model {

  static let mockModel = Model(
    id: 202,
    name: "Model1",
    mainFileName: "Model.usdz",
    mainFileSize: 55238,
    mainFilePath: "/v1/files/202/MODEL/download",
    thumbnailFileName: "thumbnail.jpg",
    thumbnailFileSize: 21961,
    thumbnailFilePath: "/v1/files/202/THUMBNAIL/download",
    viewsCount: 0,
    isFavorite: false,
    fileType: "3dModel",
    description: "Model1 Description"
  )
  
}

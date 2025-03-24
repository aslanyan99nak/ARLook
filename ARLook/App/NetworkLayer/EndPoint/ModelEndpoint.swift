//
//  ModelEndpoint.swift
//  ARLook
//
//  Created by Narek on 17.02.25.
//

import Foundation
import Moya

enum ModelEndpoint {

  case getList
  case upload(data: UploadDataModel)
  case download(path: String, id: String, name: String)
  case get(id: String)
  case delete(id: String)
  case addViewCount(id: String)
  case favorite(id: String)

}

extension ModelEndpoint: MultiTargetType {

  var path: String {
    switch self {
    case .getList: "/files/list"
    case .upload: "/files/upload"
    case let .download(path, _, _): path
    case let .get(id): "/files/\(id)"
    case let .delete(id): "/files/\(id)"
    case let .addViewCount(id): "/files/\(id)/views"
    case let .favorite(id): "/files/\(id)/favourite"
    }
  }

  var method: Moya.Method {
    switch self {
    case .get, .getList, .download: .get
    case .upload: .post
    case .delete: .delete
    case .addViewCount, .favorite: .put
    }
  }

  var parameters: Parameter {
    switch self {
    case .upload: return [:]
    case .addViewCount:
      return ["addedViewCounts": 1]
    default: return [:]
    }
  }

  var headers: Header? {
    switch self {
    case .getList:
      return [:]
    case .upload:
      return [:]
    case .download:
      var dict = [String: String]()
      dict["Accept"] = "application/octet-stream"
      dict["Connection"] = "keep-alive"
      dict["Content-Type"] = "application/json"
      return dict
    default: return [:]
    }
  }

  var task: Task {
    switch self {
    case .getList: return .requestParameters(parameters: parameters, encoding: URLEncoding())
    case let .upload(data: dataModel):
      var formData: [MultipartFormData] = []
      let modelMimeType = ".usdz"
      let thumbnailMimeType = ".jpg"
      guard let fileData = dataModel.file else {
        return .uploadMultipart(formData)
      }
      formData.append(
        MultipartFormData(
          provider: .data(fileData),
          name: "file",
          fileName: "Model" + modelMimeType
        )
      )
      
      if let thumbnailFileData = dataModel.thumbnailFile {
        formData.append(
          MultipartFormData(
            provider: .data(thumbnailFileData),
            name: "file",
            fileName: "thumbnail" + thumbnailMimeType
          )
        )
      }
      
      if let name = dataModel.name {
        formData.append(MultipartFormData(provider: .data(name.data(using: .utf8)!), name: "name"))
      }

      if let description = dataModel.description {
        formData.append(MultipartFormData(provider: .data(description.data(using: .utf8)!), name: "description"))
      }

      if let filetype = dataModel.filetype {
        formData.append(MultipartFormData(provider: .data(filetype.data(using: .utf8)!), name: "fileType"))
      }

      return .uploadMultipart(formData)
    case let .download(_, id, name):
      return .downloadDestination { temporaryURL, response in
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory
          .appendingPathComponent(id)
          .appendingPathComponent(name + ".usdz")
        return (destinationURL, [.removePreviousFile, .createIntermediateDirectories])
      }
    default: return .requestParameters(parameters: parameters, encoding: JSONEncoding())
    }
  }

}

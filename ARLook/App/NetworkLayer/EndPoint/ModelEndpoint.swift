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
  case download(id: String)
  case get(id: String)
  case delete(id: String)

}

extension ModelEndpoint: MultiTargetType {

  var path: String {
    switch self {
    case .getList: "/files/list"
    case .upload: "/files/upload"
    case let .download(id): "files/\(id)/download"
    case let .get(id): "/files/\(id)"
    case let .delete(id): "/files/\(id)"
    }
  }

  var method: Moya.Method {
    switch self {
    case .get, .getList, .download: .get
    case .upload: .post
    case .delete: .delete
    }
  }

  var parameters: Parameter {
    switch self {
    case .upload: return [:]
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
      let mimeType = ".usdz"
      guard let fileData = dataModel.file else {
        return .uploadMultipart(formData)
      }
      formData.append(
        MultipartFormData(
          provider: .data(fileData),
          name: "file",
          fileName: "Model" + mimeType
        )
      )
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
    case let .download(id: id):
      return .downloadDestination { temporaryURL, response in
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent(id + ".usdz")
        return (destinationURL, [.removePreviousFile, .createIntermediateDirectories])
      }
    default: return .requestParameters(parameters: parameters, encoding: JSONEncoding())
    }
  }

}

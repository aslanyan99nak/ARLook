//
//  UploadDataModel.swift
//  ARLook
//
//  Created by Narek on 25.02.25.
//

import Foundation

struct UploadDataModel: Codable {

  let file: Data?
  let name: String?
  let description: String?
  let filetype: String?
  // let tumbnail: Data?

}

struct EmptyModel: Codable {}

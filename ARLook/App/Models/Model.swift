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
  let fileName: String?
  let fileType: String?
  let description: String?
  
  var isLoading: Bool = false
  var loadingProgress: CGFloat = 0
  var viewCountString: String = "167K"
  
  var localFileURL: URL? {
    guard let id else { return nil }
    let fileManager = FileManager.default
    guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    else { return nil }
    let fileURL = documentsDirectory.appendingPathComponent("\(id).usdz")
    return fileManager.fileExists(atPath: fileURL.path()) ? fileURL : nil
  }
  
  enum CodingKeys: CodingKey {
    
    case id, name, fileName, fileType, description
    
  }
  
}

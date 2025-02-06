//
//  ModelManager.swift
//  ARLook
//
//  Created by Narek Aslanyan on 05.02.25.
//

import Foundation

class ModelManager {
  
  static let shared = ModelManager()
  
  private init() { }
  
  func saveFile(
    from sourceURL: URL,
    to destinationFileName: String,
    completion: @escaping (Bool, URL?) -> Void
  ) {
    let fileManager = FileManager.default

    do {
      let destinationURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent(destinationFileName)

      // Remove existing file if it exists
      if fileManager.fileExists(atPath: destinationURL.path) {
        try fileManager.removeItem(at: destinationURL)
      }

      // Copy the file
      try fileManager.copyItem(at: sourceURL, to: destinationURL)

      print("✅ File saved at:", destinationURL)
      completion(true, destinationURL)
    } catch {
      print("❌ Error saving file:", error.localizedDescription)
      completion(false, nil)
    }
  }

  func deleteFile(
    by fileName: String,
    completion: @escaping (Bool, URL?) -> Void
  ) {
    let fileManager = FileManager.default

    do {
      let destinationURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent(fileName)

      // Remove existing file if it exists
      if fileManager.fileExists(atPath: destinationURL.path) {
        try fileManager.removeItem(at: destinationURL)
        completion(true, destinationURL)
      } else {
        print("❌ File not exists:", destinationURL)
        completion(false, nil)
      }

    } catch {
      print("❌ Can't delete file:", error.localizedDescription)
      completion(false, nil)
    }
  }

  func loadFiles() -> [String] {
    let fileManager = FileManager.default
    let destinationURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    do {
      let fileURLs = try fileManager.contentsOfDirectory(
        at: destinationURL, includingPropertiesForKeys: nil)
      return fileURLs.map { $0.lastPathComponent }
    } catch {
      print("Error loading files: \(error.localizedDescription)")
      return []
    }
  }

  func checkFileExists(fileName: String, completion: (Bool, URL?) -> Void) {
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsURL.appendingPathComponent(fileName)
    let isExists = fileManager.fileExists(atPath: fileURL.path)
    isExists ? completion(isExists, fileURL) : completion(isExists, nil)
  }
  
}

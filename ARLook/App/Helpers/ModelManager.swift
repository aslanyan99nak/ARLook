//
//  ModelManager.swift
//  ARLook
//
//  Created by Narek Aslanyan on 05.02.25.
//

import Foundation
import RealityFoundation
@preconcurrency import SceneKit
import UIKit

class ModelManager {

  static let shared = ModelManager()

  private init() {}

  let mockFiles: [String] = [
    "Model1", "Model2", "Model3", "Model4",
    "Model5", "Model6", "Model7", "Model8",
    "Model9", "Model10", "Model11", "Model12",
    "Model13", "Model14", "Model15", "Model16",
    "Model17", "Model18", "Model19", "Model20",
  ]

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

  @available(iOS 18, visionOS 1, *)
  func saveFile(
    fileName: String,
    entity: Entity,
    completion: @escaping (Bool, URL?) -> Void
  ) async {
    let fileManager = FileManager.default

    do {
      let destinationURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent(fileName)

      if fileManager.fileExists(atPath: destinationURL.path) {
        try fileManager.removeItem(at: destinationURL)
      }

      try await entity.write(to: destinationURL)

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

  func thumbnail(for modelName: String, size: CGSize, time: TimeInterval = 0) -> UIImage? {
    let device = MTLCreateSystemDefaultDevice()
    let renderer = SCNRenderer(device: device, options: [:])
    renderer.autoenablesDefaultLighting = true

    guard let scene = SCNScene(named: modelName) else { return nil }
    renderer.scene = scene
    let image = renderer.snapshot(atTime: time, with: size, antialiasingMode: .multisampling4X)
    return image
  }

  @MainActor
  func thumbnail(for url: URL, size: CGSize, time: TimeInterval = 0, completion: @escaping (UIImage?) -> Void) {
    let device = MTLCreateSystemDefaultDevice()
    let renderer = SCNRenderer(device: device, options: [:])
    renderer.autoenablesDefaultLighting = true

    DispatchQueue.global(qos: .background).async {
      if let scene = try? SCNScene(url: url, options: nil) {
        renderer.scene = scene
        DispatchQueue.main.async {
          let image = renderer.snapshot(atTime: time, with: size, antialiasingMode: .multisampling4X)
          completion(image)
        }
      } else {
        completion(nil)
      }
    }
  }

}

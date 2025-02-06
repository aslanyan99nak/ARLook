//
//  USDZPreview.swift
//  ARLook
//
//  Created by Narek Aslanyan on 31.01.25.
//

import QuickLook
import SwiftUI

struct USDZPreview: UIViewControllerRepresentable {

  let url: URL

  func makeUIViewController(context: Context) -> QLPreviewController {
    let controller = QLPreviewController()
    controller.dataSource = context.coordinator
    controller.delegate = context.coordinator
    return controller
  }

  func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    let parent: USDZPreview

    init(_ parent: USDZPreview) {
      self.parent = parent
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
      1
    }

    func previewController(
      _ controller: QLPreviewController,
      previewItemAt index: Int
    ) -> QLPreviewItem {
      parent.url as QLPreviewItem
    }
    
  }

}

//
//  ARQuickLookController.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import ARKit
import QuickLook
import RealityKit
import SwiftUI
import UIKit

struct ARQuickLookController: UIViewControllerRepresentable {

  var modelFile: URL
  let endCaptureCallback: () -> Void

  func makeUIViewController(context: Context) -> QLPreviewControllerWrapper {
    let controller = QLPreviewControllerWrapper()
    controller.prepare(modelFile: modelFile, coordinator: context.coordinator)
    return controller
  }

  func updateUIViewController(_ uiViewController: QLPreviewControllerWrapper, context: Context) {
    uiViewController.updatePreviewItem(modelFile)
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    var parent: ARQuickLookController

    init(_ parent: ARQuickLookController) {
      self.parent = parent
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
      1
    }

    func previewController(
      _ controller: QLPreviewController,
      previewItemAt index: Int
    ) -> QLPreviewItem {
      parent.modelFile as QLPreviewItem
    }

    func previewControllerWillDismiss(_ controller: QLPreviewController) {
      parent.endCaptureCallback()
    }
  }
}

class QLPreviewControllerWrapper: UIViewController {

  var qlvc = QLPreviewController()
  var qlPresented = false
  var currentURL: URL?

  func prepare(modelFile: URL, coordinator: ARQuickLookController.Coordinator) {
    currentURL = modelFile
    qlvc.dataSource = coordinator
    qlvc.delegate = coordinator
  }

  func updatePreviewItem(_ newItem: URL) {
    if newItem != currentURL {
      qlvc.reloadData()
      currentURL = newItem
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if !qlPresented {
      present(qlvc, animated: true) {
        self.qlPresented = true
      }
    }
  }

}

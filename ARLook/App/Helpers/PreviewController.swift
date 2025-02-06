//
//  PreviewController.swift
//  ARLook
//
//  Created by Narek Aslanyan on 31.01.25.
//

import QuickLook
import SwiftUI

struct PreviewController: UIViewControllerRepresentable {

  let url: URL
  @Binding var isPresented: Bool

  func makeUIViewController(context: Context) -> UINavigationController {
    let controller = QLPreviewController()
    controller.dataSource = context.coordinator
    controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .done, target: context.coordinator,
      action: #selector(context.coordinator.dismiss)
    )

    let navigationController = UINavigationController(
      rootViewController: controller
    )
    return navigationController
  }

  func updateUIViewController(
    _ uiViewController: UINavigationController,
    context: Context
  ) {

  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(parent: self)
  }

  class Coordinator: QLPreviewControllerDataSource {
    let parent: PreviewController

    init(parent: PreviewController) {
      self.parent = parent
    }

    func numberOfPreviewItems(
      in controller: QLPreviewController
    ) -> Int {
      return 1
    }

    func previewController(
      _ controller: QLPreviewController,
      previewItemAt index: Int
    ) -> QLPreviewItem {
      return parent.url as QLPreviewItem
    }

    @objc func dismiss() {
      parent.isPresented = false
    }

  }
}

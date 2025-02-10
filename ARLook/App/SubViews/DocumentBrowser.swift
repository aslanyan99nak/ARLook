//
//  DocumentBrowser.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentBrowser: UIViewControllerRepresentable {

  let startingDir: URL

  func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentBrowser>)
    -> UIDocumentPickerViewController
  {
    let controller = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item])
    controller.directoryURL = startingDir
    return controller
  }

  func updateUIViewController(
    _ uiViewController: UIDocumentPickerViewController,
    context: UIViewControllerRepresentableContext<DocumentBrowser>
  ) {}

}

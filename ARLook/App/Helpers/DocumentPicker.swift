//
//  DocumentPicker.swift
//  ARLook
//
//  Created by Narek Aslanyan on 31.01.25.
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {

  var onPick: (URL) -> Void

  func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
    let picker = UIDocumentPickerViewController(
      forOpeningContentTypes: [UTType.usdz], asCopy: true)
    picker.delegate = context.coordinator
    picker.allowsMultipleSelection = false
    return picker
  }

  func updateUIViewController(
    _ uiViewController: UIDocumentPickerViewController,
    context: Context
  ) {}

  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }

  class Coordinator: NSObject, UIDocumentPickerDelegate {

    let parent: DocumentPicker

    init(_ parent: DocumentPicker) {
      self.parent = parent
    }

    func documentPicker(
      _ controller: UIDocumentPickerViewController,
      didPickDocumentsAt urls: [URL]
    ) {
      if let url = urls.first {
        parent.onPick(url)
      }
    }
  }

}

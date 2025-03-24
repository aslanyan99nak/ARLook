//
//  ImagePicker.swift
//  ARLook
//
//  Created by Narek on 19.02.25.
//

import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {

  @Binding var image: UIImage?
  @Binding var isShowPicker: Bool

  func makeUIViewController(context: Context) -> PHPickerViewController {
    var config = PHPickerConfiguration()
    config.filter = .images
    let picker = PHPickerViewController(configuration: config)
    picker.delegate = context.coordinator
    return picker
  }

  func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, PHPickerViewControllerDelegate {

    let parent: ImagePicker

    init(_ parent: ImagePicker) {
      self.parent = parent
    }

    func picker(
      _ picker: PHPickerViewController,
      didFinishPicking results: [PHPickerResult]
    ) {
      picker.dismiss(animated: true)

      guard let provider = results.first?.itemProvider,
        provider.canLoadObject(ofClass: UIImage.self)
      else { return }

      provider.loadObject(ofClass: UIImage.self) { image, _ in
        DispatchQueue.main.async { [weak self] in
          guard let self else { return }
          parent.image = image as? UIImage
          parent.isShowPicker = false
        }
      }
    }
    
  }

}

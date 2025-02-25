//
//  ShareMenuItemsView.swift
//  ARLook
//
//  Created by Narek on 25.02.25.
//

import SwiftUI

struct ShareMenuItemsView: View {

  @State private var scale: CGFloat = 1.0
  @Binding var isDefaultImage: Bool
  @Binding var scannedText: String?
  @Binding var selectedImage: UIImage?

  var chooseFromGalleryAction: (() -> Void)?

  private var foreverAnimation: Animation {
    Animation
      .linear(duration: 1)
      .repeatForever()
  }

  var body: some View {
    menuItemsView
  }

  @ViewBuilder
  private var menuItemsView: some View {
    if let selectedImage {
      Menu {
        sharelinkView
        shareImageView
        if chooseFromGalleryAction.isNotNil {
          galleryButton
        }
      } label: {
        Image(uiImage: selectedImage)
          .renderingMode(isDefaultImage ? .template : .original)
          .resizable()
          .clipShape(RoundedRectangle(cornerRadius: 24))
          .frame(width: 300, height: 300)
          .shadow(radius: 10)
          .padding(.top, 16)
          .if(isDefaultImage) { view in
            view
              .scaleEffect(scale)
              .onAppear {
                withAnimation(self.foreverAnimation) { self.scale = 0.8 }
              }
          }
      }
      .padding(.top, 20)
    }
  }

  @ViewBuilder
  private var sharelinkView: some View {
    if let selectedImage, let scannedText, let url = URL(string: scannedText) {
      let preview = SharePreview(
        url.absoluteString,
        image: Image(uiImage: selectedImage),
        icon: Image(.appIcon)
      )

      ShareLink(item: url, preview: preview) {
        HStack(spacing: 4) {
          Text(LocString.shareLink)
            .dynamicFont()

          Image(systemName: Image.link)
            .resizable()
            .frame(width: 16, height: 16)
        }
      }
    }
  }

  @ViewBuilder
  private var shareImageView: some View {
    if let selectedImage, let scannedText, let url = URL(string: scannedText) {
      let preview = SharePreview(
        url.absoluteString,
        image: Image(uiImage: selectedImage),
        icon: Image(.appIcon)
      )

      ShareLink(item: Image(uiImage: selectedImage), preview: preview) {
        HStack(spacing: 4) {
          Text(LocString.shareImage)
            .dynamicFont()

          Image(systemName: Image.qrCode)
            .resizable()
            .frame(width: 16, height: 16)
        }
      }
    }
  }

  private var galleryButton: some View {
    Button {
      chooseFromGalleryAction?()
    } label: {
      HStack(spacing: 4) {
        Text(LocString.chooseFromGallery)
          .dynamicFont()

        Image(systemName: Image.gallery)
          .resizable()
          .frame(width: 16, height: 16)
      }
    }
  }

}

#Preview {
  ShareMenuItemsView(
    isDefaultImage: .constant(true),
    scannedText: .constant("sd"),
    selectedImage: .constant(nil),
    chooseFromGalleryAction: {}
  )
}

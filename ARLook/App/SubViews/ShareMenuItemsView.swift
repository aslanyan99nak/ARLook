//
//  ShareMenuItemsView.swift
//  ARLook
//
//  Created by Narek on 25.02.25.
//

import SwiftUI

struct ShareMenuItemsView: View {

  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue
  @State private var scale: CGFloat = 1.0
  @Binding var isDefaultImage: Bool
  @Binding var scannedText: String?
  @Binding var selectedImage: UIImage?

  var isMenu: Bool = true
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
      Image(uiImage: selectedImage)
        .renderingMode(isDefaultImage ? .template : .original)
        .resizable()
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .frame(width: 300, height: 300)
        .shadow(radius: 10)
        .padding(.top, 16)
        .foregroundStyle(accentColorType.color)
        .if(isDefaultImage) { view in
          view
            .padding(.top, 10)
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
            .background(
              RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                .padding(2)
            )
            .scaleEffect(scale)
            .onAppear {
              withAnimation(self.foreverAnimation) { self.scale = 0.8 }
            }
        }
        .if(isMenu) { view in
          Menu {
            sharelinkView
            shareImageView
            if chooseFromGalleryAction.isNotNil {
              galleryButton
            }
          } label: {
            view
              .foregroundStyle(accentColorType.color)
          }
          .padding(.top, 20)
        }
        .if(!isMenu) { view in
          VStack(spacing: 30) {
            Button {
              chooseFromGalleryAction?()
            } label: {
              view
            }
            HStack(spacing: 30) {
              sharelinkView
              shareImageView
            }
          }
        }
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
        if isMenu {
          HStack(spacing: 4) {
            Text(LocString.shareLink)
              .dynamicFont()

            Image(systemName: Image.link)
          }
        } else {
          ZStack {
            Capsule()
              .fill(accentColorType.color)
              .frame(width: 100, height: 70)

            Image(.share)
              .renderingMode(.template)
              .resizable()
              .frame(width: 34, height: 34)
              .foregroundStyle(.white)
          }
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
        if isMenu {
          HStack(spacing: 4) {
            Text(LocString.shareImage)
              .dynamicFont()

            Image(systemName: Image.qrCode)
              .resizable()
              .frame(width: 16, height: 16)
          }
        } else {
          //          Image(.shareImageButton)
          ZStack {
            Capsule()
              .fill(accentColorType.color)
              .frame(width: 100, height: 70)

            Image(.paperClip)
              .renderingMode(.template)
              .resizable()
              .frame(width: 34, height: 34)
              .foregroundStyle(.white)
          }
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
    scannedText: .constant(nil),
    selectedImage: .constant(UIImage(named: Image.qrEmpty)),
    chooseFromGalleryAction: {}
  )
}

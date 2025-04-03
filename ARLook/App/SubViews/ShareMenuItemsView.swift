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
    if UIDevice.isVision {
      visionContentView
    } else {
      menuItemsView
    }
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
            shareLinkView
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
              shareLinkView
              shareImageView
            }
          }
        }
    }
  }

  @ViewBuilder
  private var shareLinkView: some View {
    if let selectedImage, let scannedText, let url = URL(string: scannedText) {
      let preview = SharePreview(
        url.absoluteString,
        image: Image(uiImage: selectedImage),
        icon: Image(.appIcon)
      )

      ShareLink(item: url, preview: preview) {
        shareLinkContentView
      }
      .if(UIDevice.isVision) { view in
        view
          .linearGradientBackground()
      }
    }
  }

  @ViewBuilder
  private var shareLinkContentView: some View {
    if isMenu {
      HStack(spacing: 4) {
        Text(LocString.shareLink)
          .dynamicFont()

        Image(systemName: Image.link)
      }
    } else {
      if UIDevice.isVision {
        shareLinkVisionContentView
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

  private var shareLinkVisionContentView: some View {
    HStack(spacing: 0) {
      Image(.share)
        .padding(.trailing, 24)

      Text(LocString.shareLink)
        .dynamicFont()
    }
    .padding(.horizontal, 40)
    .frame(height: 80)
  }

  private var shareImageVisionContentView: some View {
    HStack(spacing: 0) {
      Image(.shareImageIcon)
        .padding(.trailing, 24)

      Text(LocString.shareImage)
        .dynamicFont()
    }
    .padding(.horizontal, 40)
    .frame(height: 80)
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
        shareImageContentView
      }
      .if(UIDevice.isVision) { view in
        view
          .linearGradientBackground()
      }
    }
  }

  @ViewBuilder
  private var shareImageContentView: some View {
    if isMenu {
      HStack(spacing: 4) {
        Text(LocString.shareImage)
          .dynamicFont()

        Image(systemName: Image.qrCode)
          .resizable()
          .frame(width: 16, height: 16)
      }
    } else {
      if UIDevice.isVision {
        shareImageVisionContentView
      } else {
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

  @ViewBuilder
  private var visionContentView: some View {
    if let selectedImage {
      Image(uiImage: selectedImage)
        .renderingMode(isDefaultImage ? .template : .original)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 125, height: 125)
        .padding(50)
        .scaleHoverEffect()
        .if(isDefaultImage) { view in
          view
            .foregroundStyle(.white)
        }
        .if(!isMenu) { view in
          VStack(spacing: 30) {
            Button {
              chooseFromGalleryAction?()
            } label: {
              view
            }
            .linearGradientBackground(shapeType: .circle)
            .padding()

            HStack(spacing: 30) {
              shareLinkView
              shareImageView
            }
          }
        }
    }
  }

}

#Preview {
  ShareMenuItemsView(
    isDefaultImage: .constant(true),
    scannedText: .constant("dsf"),
    selectedImage: .constant(UIImage(named: Image.qrEmpty)),
    isMenu: false, chooseFromGalleryAction: {}
  )
}

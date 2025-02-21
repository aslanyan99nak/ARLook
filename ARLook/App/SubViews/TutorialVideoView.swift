//
//  TutorialVideoView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import SwiftUI

struct TutorialVideoView: View {

  @EnvironmentObject var appModel: AppDataModel
  @Environment(\.colorScheme) private var colorScheme
  @State var isShowing = false

  let url: URL
  let isInReviewSheet: Bool

  private let textDelay: TimeInterval = 0.3
  private let animationDuration: TimeInterval = 4
  
  private var isDarkMode: Bool {
    colorScheme == .dark
  }

  var body: some View {
    contentView
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + textDelay) {
          withAnimation {
            isShowing = true
          }
        }
        if !isInReviewSheet {
          DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            appModel.orbitState = .capturing
          }
        }
      }
  }

  private var contentView: some View {
    VStack(spacing: 0) {
      playerView
        .opacity(isShowing ? 1 : 0)
        .overlay(alignment: .bottom) {
          if !isInReviewSheet {
            Text(appModel.orbit.feedbackString(isObjectFlippable: appModel.isObjectFlippable))
              .dynamicFont()
              .opacity(isShowing ? 1 : 0)
              .padding(.bottom, 16)
          }
        }
      if isInReviewSheet {
        Spacer(minLength: 28)
      }
    }
    .foregroundStyle(.white)
  }

  private var playerView: some View {
    PlayerView(
      url: url,
      isTransparent: true,
      isStacked: false,
      isInverted: isInReviewSheet && colorScheme == .light,
      shouldLoop: false
    )
  }

}

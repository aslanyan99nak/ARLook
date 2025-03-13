//
//  CaptureOverlayView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import Foundation
import RealityKit
import SwiftUI

struct CaptureOverlayView: View {

  @EnvironmentObject var appModel: AppDataModel
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
  @State private var hasDetectionFailed = false
  @State private var selectedURL: URL?
  @Binding var showInfo: Bool

  var session: ObjectCaptureSession

  private var capturingStarted: Bool {
    switch session.state {
    case .initializing, .ready, .detecting: false
    default: true
    }
  }

  private var shouldShowTutorial: Bool {
    guard appModel.orbitState == .initial,
      case .capturing = session.state,
      appModel.orbit == .orbit1
    else { return false }
    return true
  }

  private var shouldShowNextButton: Bool {
    capturingStarted && !shouldShowTutorial
  }

  private var shouldDisableCancelButton: Bool {
    shouldShowTutorial || session.state == .ready || session.state == .initializing
  }

  private var rotationAngle: Angle {
    switch deviceOrientation {
    case .landscapeLeft: Angle(degrees: 90)
    case .landscapeRight: Angle(degrees: -90)
    case .portraitUpsideDown: Angle(degrees: 180)
    default: Angle(degrees: 0)
    }
  }

  var body: some View {
    VStack(spacing: 20) {
      HStack {
        cancelButton
          .opacity(!shouldShowTutorial ? 1 : 0)
          .disabled(shouldDisableCancelButton)
        Spacer()
        nextButton
          .opacity(shouldShowNextButton ? 1 : 0)
          .disabled(!shouldShowNextButton)
      }
      .foregroundStyle(.white)

      Spacer()

      if shouldShowTutorial,
        let url = Bundle.main.url(
          forResource: appModel.orbit.feedbackVideoName(
            isObjectFlippable: appModel.isObjectFlippable
          ),
          withExtension: "mp4"
        )
      {
        TutorialVideoView(url: url, isInReviewSheet: false)
          .frame(maxHeight: horizontalSizeClass == .regular ? 350 : 280)

        Spacer()
      } else if !capturingStarted {
        BoundingBoxGuidanceView(
          session: session,
          hasDetectionFailed: hasDetectionFailed
        )
      }

      bottomButtons
    }
    .padding()
    .padding(.horizontal, 16)
    .background(shouldShowTutorial ? Color.black.opacity(0.5) : .clear)
    .allowsHitTesting(!shouldShowTutorial)
    .animation(.default, value: shouldShowTutorial)
    .background {
      if !shouldShowTutorial && appModel.messageList.activeMessage.isNotNil {
        FeedbackView(messageList: appModel.messageList)
          .padding(.top, 100)
          .layoutPriority(1)
          .rotationEffect(rotationAngle)
      }
    }
    .task {
      for await _ in NotificationCenter.default.notifications(
        named:
          UIDevice.orientationDidChangeNotification
      ).map({ $0.name }) {
        withAnimation {
          deviceOrientation = UIDevice.current.orientation
        }
      }
    }
  }

  private var cancelButton: some View {
    Button {
      print("\(LocString.cancel) button clicked!")
      appModel.objectCaptureSession?.cancel()
    } label: {
      Text(LocString.cancel)
        .dynamicFont()
        .modifier(VisualEffectRoundedCorner())
    }
  }

  private var nextButton: some View {
    Button {
      print("\(LocString.next) button clicked!")
      appModel.setPreviewModelState(shown: true)
    } label: {
      Text(LocString.next)
        .dynamicFont()
        .modifier(VisualEffectRoundedCorner())
    }
  }

  private var bottomButtons: some View {
    VStack(spacing: 8) {
      if !capturingStarted {
        CaptureButton(
          hasDetectionFailed: $hasDetectionFailed,
          session: session,
          isObjectFlipped: appModel.isObjectFlipped
        )
        .layoutPriority(1)
      }

      HStack(alignment: .top, spacing: 0) {
        if case .capturing = session.state {
          NumOfImagesView(session: session)
            .rotationEffect(rotationAngle)
            .transition(.opacity)

          Spacer()

          ManualShotButton(session: session)
            .transition(.opacity)

        } else if case .detecting = session.state {
          ResetBoundingBoxButton(session: session)
            .transition(.opacity)

          Spacer()
        } else if case .ready = session.state {
//          FilesButton(selectedURL: $selectedURL)
//            .transition(.opacity)

          Spacer()
        }

        if !capturingStarted {
          HelpButton(showInfo: $showInfo)
            .transition(.opacity)
        }
      }
      .frame(maxWidth: .infinity)
      .opacity(shouldShowTutorial ? 0 : 1)  // Keeps tutorial view centered.
      .onChange(of: selectedURL) { oldValue, newValue in
        if oldValue != newValue {
          // Action
        }
      }
    }
  }

}

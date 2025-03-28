//
//  CapturePrimaryView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import Foundation
import RealityKit
import SwiftUI

struct CapturePrimaryView: View {

  @EnvironmentObject var appModel: AppDataModel

  // Pauses the scanning and shows tutorial pages. This sample passes it as
  // a binding to the two views so buttons can change the state.
  @State var showInfo: Bool = false
  @State private var showOnboardingView: Bool = false

  var session: ObjectCaptureSession

  private let frameHeight: CGFloat = 300
  private let gradient = LinearGradient(
    colors: [.black.opacity(0.4), .clear],
    startPoint: .top,
    endPoint: .bottom
  )

  private var shouldShowOverlayView: Bool {
    !showInfo && !appModel.showPreviewModel && !session.isPaused
      && session.cameraTracking == .normal
  }

  var body: some View {
    ZStack {
      ObjectCaptureView(
        session: session,
        cameraFeedOverlay: { gradientBackground }
      )
      .blur(radius: appModel.showPreviewModel ? 45 : 0)
      .transition(.opacity)
      .ignoresSafeArea()
      if shouldShowOverlayView {
        CaptureOverlayView(showInfo: $showInfo, session: session)
          .ignoresSafeArea()
      }
    }
    .sheet(isPresented: $showInfo) {
      HelpPageScreen(showInfo: $showInfo)
        .padding()
    }
    .sheet(
      isPresented: $showOnboardingView,
      onDismiss: { [weak appModel] in appModel?.setPreviewModelState(shown: false) },
      content: { [weak appModel] in
        if let appModel = appModel, let onboardingState = appModel.determineCurrentOnboardingState()
        {
          OnboardingView(state: onboardingState)
        }
      }
    )
    .task {
      for await userCompletedScanPass in session.userCompletedScanPassUpdates
      where userCompletedScanPass {
        appModel.setPreviewModelState(shown: true)
      }
    }
    .onChange(of: appModel.showPreviewModel) { _, showPreviewModel in
      if !showInfo {
        showOnboardingView = showPreviewModel
      }
    }
    .onChange(of: showInfo) {
      appModel.setPreviewModelState(shown: showInfo)
    }
    .onAppear {
      UIApplication.shared.isIdleTimerDisabled = true
    }
    .onDisappear {
      UIApplication.shared.isIdleTimerDisabled = false
    }
    .id(session.id)
  }

  private var gradientBackground: some View {
    VStack {
      gradient
        .frame(height: frameHeight)

      Spacer()

      gradient
        .rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
        .frame(height: frameHeight)
    }
    .ignoresSafeArea()
    .allowsHitTesting(false)
  }

}

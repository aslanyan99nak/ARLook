//
//  OnboardingView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import Foundation
import RealityKit
import SwiftUI

struct OnboardingView: View {

  @EnvironmentObject var appModel: AppDataModel
  @StateObject private var stateMachine: OnboardingStateMachine
  @Environment(\.colorScheme) private var colorScheme

  init(state: OnboardingState) {
    _stateMachine = StateObject(wrappedValue: OnboardingStateMachine(state))
  }

  var body: some View {
    ZStack {
      Color(colorScheme == .light ? .white : .black).ignoresSafeArea()
      if let session = appModel.objectCaptureSession {
        OnboardingTutorialView(onboardingStateMachine: stateMachine, session: session)
        OnboardingButtonView(onboardingStateMachine: stateMachine, session: session)
      }
    }
    .interactiveDismissDisabled(appModel.objectCaptureSession?.userCompletedScanPass ?? false)
    .allowsHitTesting(!isFinishingOrCompleted)
  }

  private var isFinishingOrCompleted: Bool {
    guard let session = appModel.objectCaptureSession else { return true }
    return session.state == .finishing || session.state == .completed
  }

}

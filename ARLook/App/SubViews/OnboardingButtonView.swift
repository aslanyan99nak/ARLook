//
//  OnboardingButtonView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import RealityKit
import SwiftUI

struct OnboardingButtonView: View {

  @EnvironmentObject var appModel: AppDataModel
  @ObservedObject var onboardingStateMachine: OnboardingStateMachine
  @State private var userHasIndicatedObjectCannotBeFlipped: Bool? = nil
  @State private var userHasIndicatedFlipObjectAnyway: Bool? = nil
  
  var session: ObjectCaptureSession

  var body: some View {
    VStack {
      HStack {
        CancelButton(buttonLabel: String.LocString.cancel)
        Spacer()
      }

      Spacer()

      VStack(spacing: 0) {
        let currentStateInputs = onboardingStateMachine.currentStateInputs()
        if currentStateInputs.contains(where: {
          $0 == .continue(isFlippable: false) || $0 == .continue(isFlippable: true)
        }) {
          continueButton
        }
        if currentStateInputs.contains(where: { $0 == .flipObjectAnyway }) {
          flipAnyway
        }
        if currentStateInputs.contains(where: {
          $0 == .skip(isFlippable: false) || $0 == .skip(isFlippable: true)
        }) {
          skipButton
        }
        if currentStateInputs.contains(where: { $0 == .finish }) {
          finishButton
        }
        if currentStateInputs.contains(where: { $0 == .objectCannotBeFlipped }) {
          canNotFlipYourObjectButton
        }
        if onboardingStateMachine.currentState == OnboardingState.tooFewImages
          || onboardingStateMachine.currentState == .secondSegmentComplete
          || onboardingStateMachine.currentState == .thirdSegmentComplete
        {
          CreateButton(buttonLabel: "", action: {})
        }
      }
      .padding(.bottom)
    }
  }
  
  private var continueButton: some View {
    CreateButton(
      buttonLabel: String.LocString.continue,
      buttonLabelColor: .white,
      shouldApplyBackground: true
    ) {
      transition(with: .continue(isFlippable: appModel.isObjectFlippable))
    }
  }
    
  private var flipAnyway: some View {
    CreateButton(
      buttonLabel: String.LocString.flipAnyway,
      buttonLabelColor: .blue
    ) {
      userHasIndicatedFlipObjectAnyway = true
      transition(with: .flipObjectAnyway)
    }
  }
  
  private var skipButton: some View {
    CreateButton(
      buttonLabel: String.LocString.skip,
      buttonLabelColor: .blue
    ) {
      transition(with: .skip(isFlippable: appModel.isObjectFlippable))
    }
  }
  
  private var finishButton: some View {
    CreateButton(
      buttonLabel: String.LocString.finish,
      buttonLabelColor: onboardingStateMachine.currentState == .thirdSegmentComplete
        ? .white : .blue,
      shouldApplyBackground: onboardingStateMachine.currentState == .thirdSegmentComplete,
      showBusyIndicator: session.state == .finishing
    ) {
      [weak session] in session?.finish()
    }
  }
  
  private var canNotFlipYourObjectButton: some View {
    CreateButton(
      buttonLabel: String.LocString.canNotFlipYourObject,
      buttonLabelColor: .blue
    ) {
      userHasIndicatedObjectCannotBeFlipped = true
      transition(with: .objectCannotBeFlipped)
    }
  }

  private func reloadData() {
    switch onboardingStateMachine.currentState {
    case .firstSegment, .dismiss:
      appModel.setPreviewModelState(shown: false)
    case .secondSegment, .thirdSegment, .additionalOrbitOnCurrentSegment:
      beginNewOrbitOrSection()
    default:
      break
    }
  }

  private func beginNewOrbitOrSection() {
    if let userHasIndicatedObjectCannotBeFlipped = userHasIndicatedObjectCannotBeFlipped {
      appModel.hasIndicatedObjectCannotBeFlipped = userHasIndicatedObjectCannotBeFlipped
    }

    if let userHasIndicatedFlipObjectAnyway = userHasIndicatedFlipObjectAnyway {
      appModel.hasIndicatedFlipObjectAnyway = userHasIndicatedFlipObjectAnyway
    }

    if !appModel.isObjectFlippable && !appModel.hasIndicatedFlipObjectAnyway {
      session.beginNewScanPass()
    } else {
      session.beginNewScanPassAfterFlip()
      appModel.isObjectFlipped = true
    }
    appModel.setPreviewModelState(shown: false)
    appModel.orbitState = .initial
    appModel.orbit = appModel.orbit.next()
  }

  private func transition(with input: OnboardingUserInput) {
    guard onboardingStateMachine.enter(input) else {
      print("Could not move to new state in User Guide state machine")
      return
    }
    reloadData()
  }
  
}

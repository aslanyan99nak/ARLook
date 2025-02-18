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
  @AppStorage(CustomColorScheme.defaultKey) var colorScheme = CustomColorScheme.defaultValue
  @State private var userHasIndicatedObjectCannotBeFlipped: Bool? = nil
  @State private var userHasIndicatedFlipObjectAnyway: Bool? = nil

  init(state: OnboardingState) {
    _stateMachine = StateObject(wrappedValue: OnboardingStateMachine(state))
  }

  private var isFinishingOrCompleted: Bool {
    guard let session = appModel.objectCaptureSession else { return true }
    return session.state == .finishing || session.state == .completed
  }

  private let onboardingStateToTutorialNameMapOnIphone: [OnboardingState: String] = [
    .flipObject: Video.iPhoneFixedHeight2,
    .flipObjectASecondTime: Video.iPhoneFixedHeight3,
    .captureFromLowerAngle: Video.iPhoneFixedHeightUnflippableLow,
    .captureFromHigherAngle: Video.iPhoneFixedHeightUnflippableHigh,
  ]

  private let onboardingStateToTutorialNameMapOnIpad: [OnboardingState: String] = [
    .flipObject: Video.iPadFixedHeight2,
    .flipObjectASecondTime: Video.iPadFixedHeight3,
    .captureFromLowerAngle: Video.iPadFixedHeightUnflippableLow,
    .captureFromHigherAngle: Video.iPadFixedHeightUnflippableHigh,
  ]

  private let onboardingStateToTitleMap: [OnboardingState: String] = [
    .tooFewImages: LocString.tooFewImagesTitle,
    .firstSegmentNeedsWork: LocString.firstSegmentNeedsWorkTitle,
    .firstSegmentComplete: LocString.firstSegmentCompleteTitle,
    .secondSegmentNeedsWork: LocString.secondSegmentNeedsWorkTitle,
    .secondSegmentComplete: LocString.secondSegmentCompleteTitle,
    .thirdSegmentNeedsWork: LocString.thirdSegmentNeedsWorkTitle,
    .thirdSegmentComplete: LocString.thirdSegmentCompleteTitle,
    .flipObject: LocString.flipObjectTitle,
    .flipObjectASecondTime: LocString.flipObjectASecondTimeTitle,
    .flippingObjectNotRecommended: LocString
      .flippingObjectNotRecommendedTitle,
    .captureFromLowerAngle: LocString.captureFromLowerAngleTitle,
    .captureFromHigherAngle: LocString.captureFromHigherAngleTitle,
  ]

  private let onboardingStateTodetailTextMap: [OnboardingState: String] = [
    .tooFewImages: String(format: LocString.tooFewImagesDetail, AppDataModel.minNumImages),
    .firstSegmentNeedsWork: LocString.firstSegmentNeedsWorkDetail,
    .firstSegmentComplete: LocString.firstSegmentCompleteDetail,
    .secondSegmentNeedsWork: LocString.secondSegmentNeedsWorkDetail,
    .secondSegmentComplete: LocString.secondSegmentCompleteDetail,
    .thirdSegmentNeedsWork: LocString.thirdSegmentNeedsWorkDetail,
    .thirdSegmentComplete: LocString.thirdSegmentCompleteDetail,
    .flipObject: LocString.flipObjectDetail,
    .flipObjectASecondTime: LocString.flipObjectASecondTimeDetail,
    .flippingObjectNotRecommended: LocString
      .flippingObjectNotRecommendedDetail,
    .captureFromLowerAngle: LocString.captureFromLowerAngleDetail,
    .captureFromHigherAngle: LocString.captureFromHigherAngleDetail,
  ]

  private var shouldShowTutorialInReview: Bool {
    switch stateMachine.currentState {
    case .flipObject, .flipObjectASecondTime, .captureFromLowerAngle,
      .captureFromHigherAngle:
      true
    default: false
    }
  }

  private var detailText: String {
    onboardingStateTodetailTextMap[stateMachine.currentState] ?? ""
  }

  private var title: String {
    onboardingStateToTitleMap[stateMachine.currentState] ?? ""
  }

  private var tutorialUrl: URL? {
    let videoName: String
    if UIDevice.isPad {
      videoName =
        onboardingStateToTutorialNameMapOnIpad[stateMachine.currentState]
        ?? Video.iPadFixedHeight1
    } else {
      videoName =
        onboardingStateToTutorialNameMapOnIphone[stateMachine.currentState]
        ?? Video.iPhoneFixedHeight1
    }
    return Bundle.main.url(forResource: videoName, withExtension: "mp4")
  }

  var body: some View {
    ZStack {
      if appModel.objectCaptureSession.isNotNil {
        onboardingTutorialView
      }
    }
    .interactiveDismissDisabled(
      appModel.objectCaptureSession?.userCompletedScanPass ?? false
    )
    .allowsHitTesting(!isFinishingOrCompleted)
    .customColorScheme($colorScheme)
  }

  private var onboardingTutorialView: some View {
    VStack {
      HStack {
        CancelButton(buttonLabel: LocString.cancel)
        Spacer()
      }

      ScrollView(showsIndicators: false) {
      if shouldShowTutorialInReview, let url = tutorialUrl {
        TutorialVideoView(url: url, isInReviewSheet: true)
          .frame(height: 200)
          .padding(.horizontal, 20)
          .padding(.bottom, 20)
      } else {
        if let session = appModel.objectCaptureSession {
          ObjectCapturePointCloudView(session: session)
            .frame(height: 200)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
      }
        VStack {
          HStack {
            ForEach(AppDataModel.Orbit.allCases) { orbit in
              if let orbitImageName = getOrbitImageName(orbit: orbit) {
                Image(systemName: orbitImageName)
                  .renderingMode(.template)
                  .resizable()
                  .frame(width: 32, height: 32)
                  .foregroundStyle(.gray)
              }
            }
          }
          .padding(.bottom)

          infoView
            .padding(.horizontal, UIDevice.isPad ? 50 : 30)
            .padding(.bottom)

          onboardingButtonView
        }
      }
    }
  }

  private var infoView: some View {
    VStack {
      Text(title)
        .dynamicFont(size: 20, weight: .bold)
        .lineLimit(3)
        .minimumScaleFactor(0.5)
        .multilineTextAlignment(.center)
        .padding(.bottom)
        .frame(maxWidth: .infinity)

      Text(detailText)
        .dynamicFont()
        .font(.body)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
      
      Spacer()
    }
  }

  private var onboardingButtonView: some View {
    VStack(spacing: 0) {
      let currentStateInputs = stateMachine.currentStateInputs()
      
      if currentStateInputs.contains(where: {
        $0 == .continue(isFlippable: false)
          || $0 == .continue(isFlippable: true)
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
      if stateMachine.currentState == OnboardingState.tooFewImages
        || stateMachine.currentState == .secondSegmentComplete
        || stateMachine.currentState == .thirdSegmentComplete
      {
        CreateButton(buttonLabel: "", action: {})
      }
    }
    .padding(.bottom)
  }

  private var continueButton: some View {
    CreateButton(
      buttonLabel: LocString.continue,
      buttonLabelColor: .white,
      shouldApplyBackground: true
    ) {
      transition(with: .continue(isFlippable: appModel.isObjectFlippable))
    }
  }

  private var flipAnyway: some View {
    CreateButton(
      buttonLabel: LocString.flipAnyway,
      buttonLabelColor: .blue
    ) {
      userHasIndicatedFlipObjectAnyway = true
      transition(with: .flipObjectAnyway)
    }
  }

  private var skipButton: some View {
    CreateButton(
      buttonLabel: LocString.skip,
      buttonLabelColor: .blue
    ) {
      transition(with: .skip(isFlippable: appModel.isObjectFlippable))
    }
  }

  @ViewBuilder
  private var finishButton: some View {
    if let session = appModel.objectCaptureSession {
      CreateButton(
        buttonLabel: LocString.finish,
        buttonLabelColor: stateMachine.currentState == .thirdSegmentComplete ? .white : .blue,
        shouldApplyBackground: stateMachine.currentState == .thirdSegmentComplete,
        showBusyIndicator: session.state == .finishing
      ) { [weak session] in
        session?.finish()
      }
    }
  }

  private var canNotFlipYourObjectButton: some View {
    CreateButton(
      buttonLabel: LocString.canNotFlipYourObject,
      buttonLabelColor: .blue
    ) {
      userHasIndicatedObjectCannotBeFlipped = true
      transition(with: .objectCannotBeFlipped)
    }
  }

  private func reloadData() {
    switch stateMachine.currentState {
    case .firstSegment, .dismiss:
      appModel.setPreviewModelState(shown: false)
    case .secondSegment, .thirdSegment, .additionalOrbitOnCurrentSegment:
      beginNewOrbitOrSection()
    default:
      break
    }
  }

  private func beginNewOrbitOrSection() {
    guard let session = appModel.objectCaptureSession else { return }
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
    guard stateMachine.enter(input) else {
      print("Could not move to new state in User Guide state machine")
      return
    }
    reloadData()
  }

  private func getOrbitImageName(orbit: AppDataModel.Orbit) -> String? {
    guard let session = appModel.objectCaptureSession else { return nil }
    let orbitCompleted = session.userCompletedScanPass
    let orbitCompleteImage = orbit <= appModel.orbit ? orbit.imageSelected : orbit.image
    let orbitNotCompleteImage = orbit < appModel.orbit ? orbit.imageSelected : orbit.image
    return orbitCompleted ? orbitCompleteImage : orbitNotCompleteImage
  }

}

//
//  OnboardingTutorialView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import Foundation
import RealityKit
import SwiftUI

/// The view that either shows the point cloud or plays the guidance tutorials on the review screens.
/// This depends on `currentState` in `onboardingStateMachine`.
struct OnboardingTutorialView: View {

  @EnvironmentObject var appModel: AppDataModel
  @ObservedObject var onboardingStateMachine: OnboardingStateMachine
  
  var session: ObjectCaptureSession

  private var shouldShowTutorialInReview: Bool {
    switch onboardingStateMachine.currentState {
    case .flipObject, .flipObjectASecondTime, .captureFromLowerAngle, .captureFromHigherAngle: true
    default: false
    }
  }

  private let onboardingStateToTutorialNameMapOnIphone: [OnboardingState: String] = [
    .flipObject: Constant.iPhoneFixedHeight2,
    .flipObjectASecondTime: Constant.iPhoneFixedHeight3,
    .captureFromLowerAngle: Constant.iPhoneFixedHeightUnflippableLow,
    .captureFromHigherAngle: Constant.iPhoneFixedHeightUnflippableHigh,
  ]

  private let onboardingStateToTutorialNameMapOnIpad: [OnboardingState: String] = [
    .flipObject: Constant.iPadFixedHeight2,
    .flipObjectASecondTime: Constant.iPadFixedHeight3,
    .captureFromLowerAngle: Constant.iPadFixedHeightUnflippableLow,
    .captureFromHigherAngle: Constant.iPadFixedHeightUnflippableHigh,
  ]

  private var tutorialUrl: URL? {
    let videoName: String
    if UIDevice.isPad {
      videoName =
        onboardingStateToTutorialNameMapOnIpad[onboardingStateMachine.currentState]
        ?? "ScanPasses-iPad-FixedHeight-1"
    } else {
      videoName =
        onboardingStateToTutorialNameMapOnIphone[onboardingStateMachine.currentState]
        ?? "ScanPasses-iPhone-FixedHeight-1"
    }
    return Bundle.main.url(forResource: videoName, withExtension: "mp4")
  }

  private let onboardingStateToTitleMap: [OnboardingState: String] = [
    .tooFewImages: String.LocalizedString.tooFewImagesTitle,
    .firstSegmentNeedsWork: String.LocalizedString.firstSegmentNeedsWorkTitle,
    .firstSegmentComplete: String.LocalizedString.firstSegmentCompleteTitle,
    .secondSegmentNeedsWork: String.LocalizedString.secondSegmentNeedsWorkTitle,
    .secondSegmentComplete: String.LocalizedString.secondSegmentCompleteTitle,
    .thirdSegmentNeedsWork: String.LocalizedString.thirdSegmentNeedsWorkTitle,
    .thirdSegmentComplete: String.LocalizedString.thirdSegmentCompleteTitle,
    .flipObject: String.LocalizedString.flipObjectTitle,
    .flipObjectASecondTime: String.LocalizedString.flipObjectASecondTimeTitle,
    .flippingObjectNotRecommended: String.LocalizedString.flippingObjectNotRecommendedTitle,
    .captureFromLowerAngle: String.LocalizedString.captureFromLowerAngleTitle,
    .captureFromHigherAngle: String.LocalizedString.captureFromHigherAngleTitle,
  ]

  private var title: String {
    onboardingStateToTitleMap[onboardingStateMachine.currentState] ?? ""
  }

  private let onboardingStateTodetailTextMap: [OnboardingState: String] = [
    .tooFewImages: String(
      format: String.LocalizedString.tooFewImagesDetailText, AppDataModel.minNumImages),
    .firstSegmentNeedsWork: String.LocalizedString.firstSegmentNeedsWorkDetailText,
    .firstSegmentComplete: String.LocalizedString.firstSegmentCompleteDetailText,
    .secondSegmentNeedsWork: String.LocalizedString.secondSegmentNeedsWorkDetailText,
    .secondSegmentComplete: String.LocalizedString.secondSegmentCompleteDetailText,
    .thirdSegmentNeedsWork: String.LocalizedString.thirdSegmentNeedsWorkDetailText,
    .thirdSegmentComplete: String.LocalizedString.thirdSegmentCompleteDetailText,
    .flipObject: String.LocalizedString.flipObjectDetailText,
    .flipObjectASecondTime: String.LocalizedString.flipObjectASecondTimeDetailText,
    .flippingObjectNotRecommended: String.LocalizedString.flippingObjectNotRecommendedDetailText,
    .captureFromLowerAngle: String.LocalizedString.captureFromLowerAngleDetailText,
    .captureFromHigherAngle: String.LocalizedString.captureFromHigherAngleDetailText,
  ]

  private var detailText: String {
    onboardingStateTodetailTextMap[onboardingStateMachine.currentState] ?? ""
  }

  var body: some View {
    VStack {
      ZStack {
        if shouldShowTutorialInReview, let url = tutorialUrl {
          TutorialVideoView(url: url, isInReviewSheet: true)
            .padding(30)
        } else {
          ObjectCapturePointCloudView(session: session)
            .padding(30)
        }

        VStack {
          Spacer()
          HStack {
            ForEach(AppDataModel.Orbit.allCases) { orbit in
              if let orbitImageName = getOrbitImageName(orbit: orbit) {
                Text(Image(systemName: orbitImageName))
                  .font(.system(size: 28))
                  .foregroundStyle(.gray)
              }
            }
          }
          .padding(.bottom)
        }
      }
      .frame(maxHeight: .infinity)

      infoView
        .frame(maxHeight: .infinity)
        .padding(.horizontal, UIDevice.isPad ? 50 : 30)
    }
  }

  private var infoView: some View {
    VStack {
      Text(title)
        .font(.largeTitle)
        .lineLimit(3)
        .minimumScaleFactor(0.5)
        .bold()
        .multilineTextAlignment(.center)
        .padding(.bottom)
        .frame(maxWidth: .infinity)

      Text(detailText)
        .font(.body)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
      Spacer()
    }
  }

  private func getOrbitImageName(orbit: AppDataModel.Orbit) -> String? {
    guard let session = appModel.objectCaptureSession else { return nil }
    let orbitCompleted = session.userCompletedScanPass
    let orbitCompleteImage = orbit <= appModel.orbit ? orbit.imageSelected : orbit.image
    let orbitNotCompleteImage = orbit < appModel.orbit ? orbit.imageSelected : orbit.image
    return orbitCompleted ? orbitCompleteImage : orbitNotCompleteImage
  }

}

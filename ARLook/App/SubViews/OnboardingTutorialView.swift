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

  private let onboardingStateToTitleMap: [OnboardingState: String] = [
    .tooFewImages: String.LocString.tooFewImagesTitle,
    .firstSegmentNeedsWork: String.LocString.firstSegmentNeedsWorkTitle,
    .firstSegmentComplete: String.LocString.firstSegmentCompleteTitle,
    .secondSegmentNeedsWork: String.LocString.secondSegmentNeedsWorkTitle,
    .secondSegmentComplete: String.LocString.secondSegmentCompleteTitle,
    .thirdSegmentNeedsWork: String.LocString.thirdSegmentNeedsWorkTitle,
    .thirdSegmentComplete: String.LocString.thirdSegmentCompleteTitle,
    .flipObject: String.LocString.flipObjectTitle,
    .flipObjectASecondTime: String.LocString.flipObjectASecondTimeTitle,
    .flippingObjectNotRecommended: String.LocString.flippingObjectNotRecommendedTitle,
    .captureFromLowerAngle: String.LocString.captureFromLowerAngleTitle,
    .captureFromHigherAngle: String.LocString.captureFromHigherAngleTitle,
  ]

  private let onboardingStateTodetailTextMap: [OnboardingState: String] = [
    .tooFewImages: String(format: String.LocString.tooFewImagesDetail, AppDataModel.minNumImages),
    .firstSegmentNeedsWork: String.LocString.firstSegmentNeedsWorkDetail,
    .firstSegmentComplete: String.LocString.firstSegmentCompleteDetail,
    .secondSegmentNeedsWork: String.LocString.secondSegmentNeedsWorkDetail,
    .secondSegmentComplete: String.LocString.secondSegmentCompleteDetail,
    .thirdSegmentNeedsWork: String.LocString.thirdSegmentNeedsWorkDetail,
    .thirdSegmentComplete: String.LocString.thirdSegmentCompleteDetail,
    .flipObject: String.LocString.flipObjectDetail,
    .flipObjectASecondTime: String.LocString.flipObjectASecondTimeDetail,
    .flippingObjectNotRecommended: String.LocString.flippingObjectNotRecommendedDetail,
    .captureFromLowerAngle: String.LocString.captureFromLowerAngleDetail,
    .captureFromHigherAngle: String.LocString.captureFromHigherAngleDetail,
  ]
  
  private var shouldShowTutorialInReview: Bool {
    switch onboardingStateMachine.currentState {
    case .flipObject, .flipObjectASecondTime, .captureFromLowerAngle, .captureFromHigherAngle: true
    default: false
    }
  }

  private var detailText: String {
    onboardingStateTodetailTextMap[onboardingStateMachine.currentState] ?? ""
  }
  
  private var title: String {
    onboardingStateToTitleMap[onboardingStateMachine.currentState] ?? ""
  }
  
  private var tutorialUrl: URL? {
    let videoName: String
    if UIDevice.isPad {
      videoName =
        onboardingStateToTutorialNameMapOnIpad[onboardingStateMachine.currentState]
        ?? Constant.iPadFixedHeight1
    } else {
      videoName =
        onboardingStateToTutorialNameMapOnIphone[onboardingStateMachine.currentState]
        ?? Constant.iPhoneFixedHeight1
    }
    return Bundle.main.url(forResource: videoName, withExtension: "mp4")
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

  private func getOrbitImageName(orbit: AppDataModel.Orbit) -> String? {
    guard let session = appModel.objectCaptureSession else { return nil }
    let orbitCompleted = session.userCompletedScanPass
    let orbitCompleteImage = orbit <= appModel.orbit ? orbit.imageSelected : orbit.image
    let orbitNotCompleteImage = orbit < appModel.orbit ? orbit.imageSelected : orbit.image
    return orbitCompleted ? orbitCompleteImage : orbitNotCompleteImage
  }

}

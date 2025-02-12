//
//  ProgressBarView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import Foundation
import RealityKit
import SwiftUI

struct ProgressBarView: View {

  @EnvironmentObject var appModel: AppDataModel
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  // The progress value from 0 to 1 which describes how much coverage is done.
  var progress: Float
  var estimatedRemainingTime: TimeInterval?
  var processingStageDescription: String?

  private var formattedEstimatedRemainingTime: String? {
    guard let estimatedRemainingTime = estimatedRemainingTime else { return nil }
    let formatter = DateComponentsFormatter()
    formatter.zeroFormattingBehavior = .pad
    formatter.unitsStyle = .positional
    formatter.allowedUnits = [.minute, .second]
    return formatter.string(from: estimatedRemainingTime)
  }

  private var remainingTimeString: String {
    String.localizedStringWithFormat(
      String.LocString.estimatedRemainingTime,
      formattedEstimatedRemainingTime ?? String.LocString.calculating)
  }

  private var numOfImages: Int {
    guard let folderManager = appModel.scanFolderManager else { return 0 }
    guard
      let urls = try? FileManager.default.contentsOfDirectory(
        at: folderManager.imagesFolder,
        includingPropertiesForKeys: nil
      )
    else {
      return 0
    }
    return urls.filter { $0.pathExtension.uppercased() == "HEIC" }.count
  }

  var body: some View {
    VStack(spacing: 12) {
      headerView

      ProgressView(value: progress)

      footerView
        .padding(.top, 10)
    }
  }

  private var headerView: some View {
    HStack(spacing: 0) {
      Text(processingStageDescription ?? String.LocString.processing)

      Spacer()

      Text(progress, format: .percent.precision(.fractionLength(0)))
        .bold()
        .monospacedDigit()
    }
    .font(.body)
  }

  private var footerView: some View {
    HStack(alignment: .center, spacing: 0) {
      VStack(alignment: .center) {
        Image(systemName: "photo")

        Text(String(numOfImages))
          .frame(alignment: .bottom)
          .font(.caption)
          .bold()
      }
      .font(.subheadline)
      .padding(.trailing, 16)

      VStack(alignment: .leading) {
        Text(String.LocString.processingModelDescription)

        Text(remainingTimeString)
      }
      .font(.subheadline)
    }
    .foregroundStyle(.secondary)
  }

}

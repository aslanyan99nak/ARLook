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
      LocString.estimatedRemainingTime,
      formattedEstimatedRemainingTime ?? LocString.calculating
    )
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
    VStack(spacing: 40) {
      headerView
      ActivityProgressView(progress: progress)
      footerView
    }
  }

  private var headerView: some View {
    HStack(spacing: 0) {
      Text(processingStageDescription ?? LocString.processing)
        .dynamicFont()

      Spacer()
    }
  }

  private var footerView: some View {
    HStack(alignment: .center, spacing: 0) {
      VStack(alignment: .center) {
        Image(systemName: Image.photo)

        Text(String(numOfImages))
          .dynamicFont(weight: .bold)
          .frame(alignment: .bottom)
      }
      .padding(.trailing, 16)

      VStack(alignment: .leading) {
        Text(LocString.processingModelDescription)
          .dynamicFont()

        Text(remainingTimeString)
          .dynamicFont()
      }
      .font(.subheadline)
    }
    .foregroundStyle(.secondary)
  }

}

#Preview {
  ProgressBarView(
    progress: 1,
    estimatedRemainingTime: TimeInterval(100),
    processingStageDescription: "dfdsgdfgdfg"
  )
}

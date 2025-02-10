//
//  ReconstructionPrimaryView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import SwiftUI

struct ReconstructionPrimaryView: View {

  @EnvironmentObject var appModel: AppDataModel
  @State private var completed: Bool = false
  @State private var cancelled: Bool = false
  let outputFile: URL

  var body: some View {
    if completed && !cancelled {
      ModelView(
        modelFile: outputFile,
        endCaptureCallback: { [weak appModel] in
          appModel?.endCapture()
        })
    } else {
      ReconstructionProgressView(
        completed: $completed,
        cancelled: $cancelled,
        outputFile: outputFile
      )
      .onAppear {
        UIApplication.shared.isIdleTimerDisabled = true
      }
      .onDisappear {
        UIApplication.shared.isIdleTimerDisabled = false
      }
      .interactiveDismissDisabled()
    }
  }

}



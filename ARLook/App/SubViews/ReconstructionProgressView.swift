//
//  ReconstructionProgressView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import SwiftUI
import RealityKit

struct ReconstructionProgressView: View {

  @EnvironmentObject var appModel: AppDataModel
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var progress: Float = 0
  @State private var estimatedRemainingTime: TimeInterval?
  @State private var processingStageDescription: String?
  @State private var pointCloud: PhotogrammetrySession.PointCloud?
  @State private var gotError: Bool = false
  @State private var error: Error?
  @State private var isCancelling: Bool = false
  @Binding var completed: Bool
  @Binding var cancelled: Bool

  let outputFile: URL

  private var isReconstructing: Bool {
    !completed && !gotError && !cancelled
  }

  var body: some View {
    VStack(spacing: 0) {
      if isReconstructing {
        HStack {
          cancelButton
            .padding(.trailing)
          Spacer()
        }
      }

      Spacer()

      Text(String.LocalizedString.processingTitle)
        .font(.largeTitle)
        .fontWeight(.bold)

      Spacer()

      progressBarView
        .padding(horizontalSizeClass == .regular ? 60.0 : 24.0)

      Spacer()
    }
    .frame(maxWidth: .infinity)
    .padding(.bottom, 20)
    .alert(
      "Failed:  " + (error.isNotNil ? "\(String(describing: error!))" : ""),
      isPresented: $gotError
    ) {
      alertOkButton
    }
    .task {
      await startReconstructionTask()
    }
  }

  private var progressBarView: some View {
    ProgressBarView(
      progress: progress,
      estimatedRemainingTime: estimatedRemainingTime,
      processingStageDescription: processingStageDescription
    )
  }

  private var cancelButton: some View {
    Button {
      print("Cancelling...")
      isCancelling = true
      appModel.photogrammetrySession?.cancel()
    } label: {
      Text(String.LocalizedString.cancel)
        .font(.headline)
        .bold()
        .padding(30)
        .foregroundStyle(.blue)
    }
  }

  private var alertOkButton: some View {
    Button {
      print("Calling restart...")
      appModel.state = .restart
    } label: {
      Text("OK")
    }
  }
  
  private func startReconstructionTask() async {
    precondition(appModel.state == .reconstructing)
    assert(appModel.photogrammetrySession.isNotNil)
    let session = appModel.photogrammetrySession!

    let outputs = UntilProcessingCompleteFilter(input: session.outputs)
    do {
      try session.process(requests: [.modelFile(url: outputFile)])
    } catch {
      print("Processing the session failed!")
    }
    await listenSessionUpdates(outputs)
    print(">>>>>>>>>> RECONSTRUCTION TASK EXIT >>>>>>>>>>>>>>>>>")
  }
  
  private func listenSessionUpdates(
    _ outputs: UntilProcessingCompleteFilter<PhotogrammetrySession.Outputs>
  ) async {
    for await output in outputs {
      switch output {
      case .inputComplete: break
      case .requestProgress(let request, let fractionComplete):
        if case .modelFile = request {
          progress = Float(fractionComplete)
        }
      case .requestProgressInfo(let request, let progressInfo):
        if case .modelFile = request {
          estimatedRemainingTime = progressInfo.estimatedRemainingTime
          processingStageDescription = progressInfo.processingStage?.processingStageString
        }
      case .requestComplete(let request, _):
        switch request {
        case .modelFile(_, _, _):
          print("RequestComplete: .modelFile")
        case .modelEntity(_, _), .bounds, .poses, .pointCloud:
          // Not supported yet
          break
        @unknown default:
          print("Received an output for an unknown request: \(String(describing: request))")
        }
      case .requestError(_, let requestError):
        if !isCancelling {
          gotError = true
          error = requestError
        }
      case .processingComplete:
        if !gotError {
          completed = true
          appModel.state = .viewing
        }
      case .processingCancelled:
        cancelled = true
        appModel.state = .restart
      case .invalidSample(id: _, reason: _), .skippedSample(id: _), .automaticDownsampling:
        continue
      case .stitchingIncomplete:
        break
      @unknown default:
        print("Received an unknown output: \(String(describing: output))")
      }
    }
  }

}

#Preview {
  ReconstructionProgressView(
    completed: .constant(true),
    cancelled: .constant(false),
    outputFile: URL(string: "www.google.com")!
  )
}

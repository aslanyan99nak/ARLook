//
//  ReconstructionProgressView.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import RealityKit
import SwiftUI

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
  @State private var isProgressCompeted: Bool = false
  @State private var isAnimate: Bool = false
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

      if !isProgressCompeted {
        VStack(spacing: 20) {
          Text(String.LocString.processingTitle)
            .dynamicFont(size: 20, weight: .bold)
          
          progressBarView
            .padding(horizontalSizeClass == .regular ? 60.0 : 24.0)
        }
      } else {
        VStack(spacing: 16) {
          completedView
          uploadButton
          viewIn3DModeButton
        }
        .frame(maxWidth: 300)
        .padding(.top, 80)
      }

      Spacer()
    }
    .frame(maxWidth: .infinity)
    .alert(
      String.LocString.failed + (error.isNotNil ? " \(String(describing: error!))" : ""),
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
      Text(String.LocString.cancel)
        .dynamicFont(weight: .bold)
        .padding(30)
        .foregroundStyle(.blue)
    }
  }

  private var alertOkButton: some View {
    Button {
      print("Calling restart...")
      appModel.state = .restart
    } label: {
      Text(String.LocString.ok)
        .dynamicFont(weight: .bold)
    }
  }

  private var completedView: some View {
    VStack(spacing: 16) {
      Text(String.LocString.completedProcess)
        .dynamicFont()

      Image(systemName: "checkmark.seal.fill")
        .renderingMode(.template)
        .resizable()
        .frame(width: 150, height: 150)
        .foregroundStyle(.green)
        .symbolEffect(.bounce, value: isAnimate)
        .onAppear {
          isAnimate = true
        }
        .onDisappear {
          isAnimate = false
        }
    }
  }

  private var uploadButton: some View {
    Button {
      print("Upload Action")
    } label: {
      HStack(spacing: 8) {
        Spacer()

        Image(systemName: "square.and.arrow.down")
          .renderingMode(.template)
          .resizable()
          .frame(width: 16, height: 16)
          .foregroundStyle(.white)

        Text(String.LocString.upload)
          .dynamicFont()
          .foregroundColor(.white)

        Spacer()
      }
      .padding()
      .background(Color.blue)
      .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }

  private var viewIn3DModeButton: some View {
    Button {
      print("View in 3D mode Action")
      completed = true
      appModel.state = .viewing
      print("OutputFile: ", outputFile)
    } label: {
      HStack(spacing: 8) {
        Spacer()

        Image(systemName: "arkit")
          .renderingMode(.template)
          .resizable()
          .frame(width: 16, height: 16)
          .foregroundStyle(.white)

        Text(String.LocString.view3DMode)
          .dynamicFont(weight: .bold)
          .foregroundColor(.white)

        Spacer()
      }
      .padding()
      .background(Color.blue)
      .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }

  private func startReconstructionTask() async {
    precondition(appModel.state == .reconstructing)
    assert(appModel.photogrammetrySession.isNotNil)
    let session = appModel.photogrammetrySession!

    let outputs = UntilProcessingCompleteFilter(input: session.outputs)
    
    let request = PhotogrammetrySession.Request.modelFile(url: outputFile, detail: .reduced)
    do {
      try session.process(requests: [request])
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
          isProgressCompeted = true
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

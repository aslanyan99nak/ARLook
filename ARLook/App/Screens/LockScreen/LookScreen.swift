//
//  LookScreen.swift
//  ARLook
//
//  Created by Narek on 21.02.25.
//

import ARKit
import Combine
import FocusEntity
import RealityKit
import SwiftUI

struct LookScreen: View {

  let fileURL: URL

  var body: some View {
    ZStack {
      ARViewContainer(fileURL: fileURL)
        .edgesIgnoringSafeArea(.all)

      buttonsStack
    }
    .toolbar(.hidden, for: .tabBar)
  }

  private var buttonsStack: some View {
    VStack {
      Spacer()
      Button {
        NotificationCenter.default.post(name: .placeModel, object: nil)
      } label: {
        Image(systemName: "plus")
          .font(.headline)
          .foregroundStyle(.black)
          .padding()
          .background(.white)
          .clipShape(Circle())
          .padding()
      }
    }
  }

}

struct ARViewContainer: UIViewRepresentable {

  @AppStorage(AccentColorType.defaultKey) var accentColorType = AccentColorType.defaultValue

  let fileURL: URL
  let arView = ARView(frame: .zero)

  func makeCoordinator() -> Coordinator {
    Coordinator(
      self,
      fileURL: fileURL,
      accentColor: UIColor(accentColorType.color)
    )
  }

  func makeUIView(context: Context) -> ARView {
    let config = ARWorldTrackingConfiguration()
    config.planeDetection = [.horizontal, .vertical]
    arView.session.run(config)

    context.coordinator.setupARView(arView, accentColor: UIColor(accentColorType.color))

    return arView
  }

  func updateUIView(_ uiView: ARView, context: Context) {}

  class Coordinator: NSObject, ARSessionDelegate {

    private let parent: ARViewContainer!
    private let fileURL: URL
    private var focusEntity: FocusEntity?
    private let accentColor: UIColor!
    private var cancellables = Set<AnyCancellable>()

    init(_ parent: ARViewContainer, fileURL: URL, accentColor: UIColor = .white) {
      self.parent = parent
      self.fileURL = fileURL
      self.accentColor = accentColor
      super.init()
    }

    func setupARView(_ arView: ARView, accentColor: UIColor) {
      arView.session.delegate = self
      focusEntity = FocusEntity(on: arView, style: .classic(color: accentColor))

      NotificationCenter.default.addObserver(self, selector: #selector(placeModel), name: .placeModel, object: nil)
    }

    @objc func placeModel() {
      guard let focusEntity = focusEntity else { return }

      let modelEntityRequest = ModelEntity.loadAsync(contentsOf: fileURL)
      modelEntityRequest
        .sink { result in
          switch result {
          case .failure(let error): print("Failed with error: \(error.localizedDescription)")
          case .finished: print("Successfully loaded model")
          }
        } receiveValue: { [weak self] modelEntity in
          guard let self else { return }
          let focusTransform = focusEntity.transformMatrix(relativeTo: nil)
          let correctedTransform = focusTransform * float4x4(simd_quatf(angle: .pi / 2 * -1, axis: [1, 0, 0]))
          let anchorEntity = AnchorEntity(world: correctedTransform)
          anchorEntity.addChild(modelEntity)
          parent.arView.scene.addAnchor(anchorEntity)
        }
        .store(in: &cancellables)
    }

  }

}

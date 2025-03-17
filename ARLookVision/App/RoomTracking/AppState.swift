//
//  RoomState.swift
//  ARLook
//
//  Created by Narek on 17.03.25.
//

import ARKit
import RealityKit
import SwiftUI

@Observable
@MainActor
class RoomState {

  enum ErrorState: Equatable {
    case noError
    case providerNotSupported
    case providerNotAuthorized
    case sessionError(ARKitSession.Error)

    static func == (lhs: RoomState.ErrorState, rhs: RoomState.ErrorState) -> Bool {
      switch (lhs, rhs) {
      case (.noError, .noError): true
      case (.providerNotSupported, .providerNotSupported): true
      case (.providerNotAuthorized, .providerNotAuthorized): true
      case (.sessionError(let lhsError), .sessionError(let rhsError)): lhsError.code == rhsError.code
      default: false
      }
    }
  }

  private let session = ARKitSession()
  private let worldTracking = WorldTrackingProvider()
  private let roomTracking = RoomTrackingProvider()
  private let handTracking = HandTrackingProvider()

  /// Root for all virtual content.
  private let contentRoot = Entity()
  /// Root for room boundary geometry.
  private let roomRoot = Entity()
  private let colliderWallsRoot = Entity()
  private let renderWallRoot = Entity()
  /// A dictionary that contains `RoomAnchor` structures.
  private var roomAnchors = [UUID: RoomAnchor]()
  /// A dictionary that contains `WorldAnchor` structures.
  private var worldAnchors = [UUID: WorldAnchor]()
  /// A dictionary that contains `ModelEntity` structures for room anchors.
  private var roomEntities = [UUID: ModelEntity]()
  private var currentRenderedWall: Entity?
  /// Material the app applies to room entities to show occlusion effects.
  private let occlusionMaterial = OcclusionMaterial()
  /// Material for current room walls.
  private var wallMaterial = UnlitMaterial(color: .blue)
  private var addedWallMaterial = UnlitMaterial(color: .white)
  /// When a person denies authorization or a data provider state changes to an error condition,
  /// the main window displays an error message based on the `errorState`.
  var errorState: ErrorState = .noError
  /// Indicates whether an immersive space is currently open.
  var isImmersive: Bool = false
  let roomParentEntity = Entity()

  init() {
    if !areAllDataProvidersSupported {
      errorState = .providerNotSupported
    }
    Task {
      if await !areAllDataProvidersAuthorized() {
        errorState = .providerNotAuthorized
      }
    }

    roomRoot.isEnabled = false
    renderWallRoot.isEnabled = true
    renderWallRoot.components[OpacityComponent.self] = .init(opacity: 0.3)
    colliderWallsRoot.components[OpacityComponent.self] = .init(opacity: 0)

    contentRoot.addChild(roomParentEntity)
    contentRoot.addChild(roomRoot)
    contentRoot.addChild(renderWallRoot)
    contentRoot.addChild(colliderWallsRoot)
  }

  /// Sets up the root entity in the scene.
  func setupContentEntity() -> Entity {
    contentRoot
  }

  private var areAllDataProvidersSupported: Bool {
    WorldTrackingProvider.isSupported && RoomTrackingProvider.isSupported && HandTrackingProvider.isSupported
  }

  func areAllDataProvidersAuthorized() async -> Bool {
    // It's sufficient to check that the authorization status isn't 'denied'.
    // If it's `notdetermined`, ARKit presents a permission pop-up menu that appears as soon
    // as the session runs.
    let authorization = await ARKitSession().queryAuthorization(for: [.worldSensing])
    return authorization[.worldSensing] != .denied
  }

  func runSession() async {
    do {
      try await session.run([worldTracking, roomTracking, handTracking])
    } catch {
      guard error is ARKitSession.Error else {
        preconditionFailure("Unexpected error \(error).")
      }
      // Session errors are handled in RoomState.monitorSessionUpdates().
    }
  }

  /// From an array of candidate walls, gets the wall whose centroid has the shortest distance to a given queryWall.
  private func getNearestWall(queryWall: Entity, candidateWalls: [Entity]) -> Entity? {
    guard let queryWall = (queryWall as? ModelEntity) else {
      logger.error("Failed to get the centroid of the query wall.")
      return nil
    }
    guard let queryWallCentroid = queryWall.centroid else {
      logger.error("Failed to get the centroid of the query wall.")
      return nil
    }

    var nearestWall: Entity?
    var nearestDistance = Float.greatestFiniteMagnitude

    for candidateWall in candidateWalls {
      guard let model = candidateWall as? ModelEntity else {
        logger.error("Failed to get the centroid of a candidate wall.")
        continue
      }
      guard let candidateWallCentroid = model.centroid else {
        logger.error("Failed to get the centroid of a candidate wall.")
        continue
      }
      let candidateToQueryDistance = distance(candidateWallCentroid, queryWallCentroid)
      if candidateToQueryDistance < nearestDistance {
        nearestWall = candidateWall
        nearestDistance = candidateToQueryDistance
      }
    }
    return nearestWall
  }

  private func updateSelectedWall(wallCandidateEntities: [Entity]) {
    guard renderWallRoot.isEnabled, let currentRenderedWall else {
      return
    }

    // Gets the nearest wall to the `currentRenderedWall`.
    guard let newWallToRender = getNearestWall(queryWall: currentRenderedWall, candidateWalls: wallCandidateEntities)
    else {
      logger.error("Failed to find the nearest wall to the rendered wall.")
      return
    }
    self.currentRenderedWall = newWallToRender
    renderWallRoot.addChild(newWallToRender)
    roomParentEntity.addChild(newWallToRender)
  }

  /// Updates the wall in front of the person when a wall isn't in a selected state.
  func updateFacingWall() {
    guard renderWallRoot.isEnabled else { return }
    // Update within 10 m.
    let distance: Float = 10

    let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
    guard let deviceAnchor, deviceAnchor.isTracked else { return }
    let deviceInOriginCoordinates = deviceAnchor.originFromAnchorTransform

    let lookAtPointInDeviceCoordinate = SIMD4<Float>(0, 0, -distance, 1)
    let lookAtPointInOriginCoordinates = deviceInOriginCoordinates * lookAtPointInDeviceCoordinate

    guard let scene = colliderWallsRoot.scene else {
      logger.error("Failed to find the scene of `colliderWallsRoot`.")
      return
    }

    let hitWall = scene.raycast(
      from: deviceInOriginCoordinates.columns.3.xyz,
      to: lookAtPointInOriginCoordinates.xyz,
      query: .nearest
    )

    guard !hitWall.isEmpty else { return }
    // Render the first hit wall.
    renderWallRoot.children.removeAll()

    let hitEntity = hitWall[0].entity
    currentRenderedWall = hitEntity
    renderWallRoot.addChild(hitEntity)
  }

  private func updateCurrentRoomWalls(for roomAnchor: RoomAnchor) async {
    let newColliderWalls = Entity()
    let wallGeometries = roomAnchor.geometries(of: .wall)
    for wallGeometry in wallGeometries {
      guard let wallMeshResource = wallGeometry.asMeshResource() else {
        continue
      }

      let wallEntity = ModelEntity(mesh: wallMeshResource, materials: [wallMaterial])
      wallEntity.transform = Transform(matrix: roomAnchor.originFromAnchorTransform)

      guard let shape = try? await ShapeResource.generateStaticMesh(from: wallMeshResource) else {
        logger.error("Failed to create ShapeResource from wall geometries.")
        continue
      }

      wallEntity.collision = CollisionComponent(shapes: [shape], isStatic: true)
      newColliderWalls.addChild(wallEntity)
    }
    colliderWallsRoot.addChild(newColliderWalls)
  }

  func processRoomTrackingUpdates() async {
    for await update in roomTracking.anchorUpdates {
      let roomAnchor = update.anchor
      switch update.event {
      case .removed:
        if roomAnchor.isCurrentRoom {
          colliderWallsRoot.children.removeAll()
          if let currentRenderedWall {
            renderWallRoot.removeChild(currentRenderedWall)
          }
        }
        roomAnchors.removeValue(forKey: roomAnchor.id)
        roomEntities[roomAnchor.id]?.removeFromParent()
        roomEntities.removeValue(forKey: roomAnchor.id)
      case .added, .updated:
        roomAnchors[roomAnchor.id] = roomAnchor
        guard let roomMeshResource = roomAnchor.geometry.asMeshResource() else { continue }
        if update.event == .added {
          let roomEntity = ModelEntity(mesh: roomMeshResource, materials: [occlusionMaterial])
          roomEntity.transform = Transform(matrix: roomAnchor.originFromAnchorTransform)
          roomEntities[roomAnchor.id] = roomEntity
          roomEntity.isEnabled = roomAnchor.isCurrentRoom
          roomRoot.addChild(roomEntity)
        } else if update.event == .updated {
          guard let roomEntity = roomEntities[roomAnchor.id] else { continue }
          roomEntity.model?.mesh = roomMeshResource
          roomEntity.transform = Transform(matrix: roomAnchor.originFromAnchorTransform)
          roomEntity.isEnabled = roomAnchor.isCurrentRoom
        }

        if roomAnchor.isCurrentRoom {
          if renderWallRoot.isEnabled {
            await updateCurrentRoomWalls(for: roomAnchor)
          }
        }
      }
    }
  }

  @MainActor
  func processTapOnEntity() {
    var newColliderWalls: [ModelEntity] = []
    colliderWallsRoot.children.forEach { entity in
      entity.children.forEach { wallEntity in
        if let wallEntity = wallEntity as? ModelEntity {
          wallEntity.model?.materials = [addedWallMaterial]
          newColliderWalls.append(wallEntity)
        }
      }
    }
    updateSelectedWall(wallCandidateEntities: newColliderWalls)
  }

  func monitorSessionUpdates() async {
    for await event in session.events {
      logger.info("\(event.description)")
      switch event {
      case .authorizationChanged(type: _, let status):
        logger.info("Authorization changed to: \(status)")
        if status == .denied {
          errorState = .providerNotAuthorized
        }
      case .dataProviderStateChanged(dataProviders: let providers, newState: let state, let error):
        logger.info("Data providers state changed: \(providers), \(state)")
        if let error {
          logger.error("Data provider reached an error state: \(error)")
          errorState = .sessionError(error)
        }
      @unknown default:
        fatalError("Unhandled new event type \(event)")
      }
    }
  }

  func removeAllWorldAnchors() async {
    for (id, _) in worldAnchors {
      do {
        try await worldTracking.removeAnchor(forID: id)
      } catch {
        logger.info("Failed to remove world anchor id \(id).")
      }
    }
  }

  /// Creates a world anchor with the input transform and adds the anchor to the world tracking provider.
  func addWorldAnchor(at transform: simd_float4x4) async {
    let worldAnchor = WorldAnchor(originFromAnchorTransform: transform)
    do {
      try await self.worldTracking.addAnchor(worldAnchor)
    } catch {
      // Adding world anchors can fail, for example when you reach the limit
      // for total world anchors per app.
      logger.error("Failed to add world anchor \(worldAnchor.id) with error: \(error).")
    }
  }

}

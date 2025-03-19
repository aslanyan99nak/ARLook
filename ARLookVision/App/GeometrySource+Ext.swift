//
//  GeometrySource+Ext.swift
//  ARLook
//
//  Created by Narek on 13.03.25.
//

import ARKit
import RealityKit

extension GeometrySource {

  /// converts between ARKit and RealityKit types.
  func asArray<T>(ofType: T.Type) -> [T] {
    let bContents = self.buffer.contents()
    let offset = self.offset
    let stride = self.stride
    let count = self.count

    var result: [T] = Array()
    result.reserveCapacity(count)

    for index in 0..<count {
      result.append(
        bContents
          .advanced(by: offset + stride * index)
          .assumingMemoryBound(to: T.self)
          .pointee
      )
    }
    return result
  }

  func asSIMD3<T>(ofType: T.Type) -> [SIMD3<T>] {
    asArray(ofType: (T, T, T).self).map { .init($0.0, $0.1, $0.2) }
  }

}

extension GeometryElement {

  func asIndexArray() -> [UInt32] {
    (0..<self.count * self.primitive.indexCount).map {
      self.buffer.contents()
        .advanced(by: $0 * self.bytesPerIndex)
        .assumingMemoryBound(to: UInt32.self).pointee
    }
  }

}

extension MeshAnchor.Geometry {

  /// Creates MeshResource from geometry.
  @MainActor
  func asMeshResource() -> MeshResource? {
    let vertices = self.vertices.asSIMD3(ofType: Float.self)
    guard !vertices.isEmpty else { return nil }
    let faceIndexArray = self.faces.asIndexArray()
    var descriptor = MeshDescriptor()
    descriptor.positions = .init(vertices)
    descriptor.materials = .allFaces(0)
    descriptor.primitives = MeshDescriptor.Primitives.triangles(faceIndexArray)

    do {
      let mesh = try MeshResource.generate(from: [descriptor])
      return mesh
    } catch {
      logger.error("Error creating MeshResource with error:\(error)")
    }
    return nil
  }

}

extension PlaneAnchor.Geometry {

  @MainActor
  func asMeshResource() -> MeshResource? {
    let vertices = self.meshVertices.asSIMD3(ofType: Float.self)
    guard !vertices.isEmpty else { return nil }
    let faceIndexArray = self.meshFaces.asIndexArray()
    var descriptor = MeshDescriptor()
    descriptor.positions = .init(vertices)
    descriptor.materials = .allFaces(0)
    descriptor.primitives = MeshDescriptor.Primitives.triangles(faceIndexArray)

    do {
      let mesh = try MeshResource.generate(from: [descriptor])
      return mesh
    } catch {
      logger.error("Error creating MeshResource with error:\(error)")
    }
    return nil
  }

}

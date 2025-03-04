//
//  Entity+Ext.swift
//  ARLook
//
//  Created by Narek on 03.03.25.
//

import RealityKit

extension Entity {

  func translate(in translation: SIMD3<Float>) {
    let transform = self.transform
    let rightVector = transform.matrix.columns.0.xyz  // Right
    let upVector = transform.matrix.columns.1.xyz  // Up
    let forwardVector = transform.matrix.columns.2.xyz  // Forward

    self.position += translation.x * rightVector
    self.position += translation.y * upVector
    self.position += translation.z * forwardVector
  }

  func rotate(in translation: SIMD3<Float>) {
    let transform = self.transform
    let rightVector = transform.matrix.columns.0.xyz  // Right (X axis)
    let upVector = transform.matrix.columns.1.xyz  // Up (Y axis)
    let rotationX = translation.y * 0.001
    let rotationY = translation.x * 0.001
    let rotationQuatX = simd_quatf(angle: rotationX, axis: rightVector)
    let rotationQuatY = simd_quatf(angle: rotationY, axis: upVector)

    self.transform.rotation = rotationQuatX * self.transform.rotation
    self.transform.rotation = rotationQuatY * self.transform.rotation
  }

}

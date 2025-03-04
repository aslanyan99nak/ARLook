//
//  Simd+Ext.swift
//  ARLook
//
//  Created by Narek on 03.03.25.
//

import simd

extension simd_float4 {

  var xyz: SIMD3<Float> {
    SIMD3<Float>(x: self.x, y: self.y, z: self.z)
  }

}

//
//  Simd+Ext.swift
//  ARLook
//
//  Created by Narek on 19.03.25.
//


extension SIMD4 {

  /// Retrieves first 3 elements
  var xyz: SIMD3<Scalar> {
    self[SIMD3(0, 1, 2)]
  }

}

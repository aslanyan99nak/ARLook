//
//  Data+Ext.swift
//  ARLook
//
//  Created by Narek Aslanyan on 03.02.25.
//

import Foundation

extension Data {

  var convertToString: String? {
    String(data: self, encoding: .utf8)
  }

}

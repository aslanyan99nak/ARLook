//
//  File.swift
//  ARLook
//
//  Created by Narek Aslanyan on 03.02.25.
//

import Foundation

extension String {

  var toBase64: String {
    let data = Data(self.utf8)
    return data.base64EncodedString()
  }

}

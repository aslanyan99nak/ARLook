//
//  File.swift
//  ARLook
//
//  Created by Narek Aslanyan on 03.02.25.
//

import Foundation

extension String {

  var convertedFileNameFromURLString: String? {
    self.components(separatedBy: "/").last
  }
  
  var localized: String {
    NSLocalizedString(self, comment: "")
  }

}

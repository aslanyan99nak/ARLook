//
//  Int+Ext.swift
//  ARLook
//
//  Created by Narek on 13.03.25.
//

import Foundation

extension Int64 {

  var fileSizeFormatted: String {
    if self <= 0 {
      return "0 B"
    }

    let units = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
    let logBase = log10(Double(self)) / log10(1024.0)
    let digitGroups = Int(logBase)

    let size = Double(self) / pow(1024.0, Double(digitGroups))
    return String(format: "%.1f %@", size, units[digitGroups])
  }

  var formattedViewCount: String {
    if self < 1_000 {
      return "\(self)"
    }

    let units = ["K", "M", "B", "T"]
    var value = Double(self)
    var unitIndex = -1

    while value >= 1_000, unitIndex < units.count - 1 {
      value /= 1_000
      unitIndex += 1
    }

    return String(format: "%.1f%@", value, units[unitIndex])
  }

}

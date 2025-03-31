//
//  ModelType.swift
//  ARLook
//
//  Created by Narek on 31.03.25.
//

import SwiftUI

enum ModelType: String, CaseIterable {

  case all
  case favorite
  case recent

  var name: String {
    switch self {
    case .all: LocString.all
    case .favorite: LocString.favorite
    case .recent: LocString.recent
    }
  }

  var icon: Image? {
    switch self {
    case .all: nil
    case .favorite: Image(systemName: Image.favorite)
    case .recent: Image(systemName: Image.recent)
    }
  }

  var id: Int {
    switch self {
    case .all: 0
    case .favorite: 1
    case .recent: 2
    }
  }

}

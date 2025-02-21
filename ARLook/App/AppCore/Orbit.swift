//
//  Orbit.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

import SwiftUI

extension AppDataModel {

  enum Orbit: Int, CaseIterable, Identifiable, Comparable {

    case orbit1, orbit2, orbit3

    var id: Int {
      rawValue
    }

    var image: String {
      let imagesByIndex = [Image.circle1, Image.circle2, Image.circle3]
      return imagesByIndex[id]
    }

    var imageSelected: String {
      let imagesByIndex = [Image.circle1Fill, Image.circle2Fill, Image.circle3Fill]
      return imagesByIndex[id]
    }

    func next() -> Self {
      let currentIndex = Self.allCases.firstIndex(of: self)!
      let nextIndex = Self.allCases.index(after: currentIndex)
      return Self.allCases[
        nextIndex == Self.allCases.endIndex ? Self.allCases.endIndex - 1 : nextIndex]
    }

    func feedbackString(isObjectFlippable: Bool) -> String {
      switch self {
      case .orbit1:
        return LocString.segment1Feedback
      case .orbit2, .orbit3:
        if isObjectFlippable {
          return LocString.segment2And3FlippableFeedback
        } else {
          if case .orbit2 = self {
            return LocString.segment2UnflippableFeedback
          }
          return LocString.segment3UnflippableFeedback
        }
      }
    }

    @MainActor
    func feedbackVideoName(
      isObjectFlippable: Bool
    ) -> String {
      switch self {
      case .orbit1:
        return UIDevice.isPad ? Video.iPadFixedHeight1 : Video.iPhoneFixedHeight1
      case .orbit2:
        let iPhoneVideoName =
          isObjectFlippable ? Video.iPhoneFixedHeight2 : Video.iPhoneFixedHeightUnflippableLow
        let iPadVideoName =
          isObjectFlippable
          ? Video.iPadFixedHeight2 : Video.iPadFixedHeightUnflippableLow
        return UIDevice.isPad ? iPadVideoName : iPhoneVideoName
      case .orbit3:
        let iPhoneVideoName =
          isObjectFlippable
          ? Video.iPhoneFixedHeight3 : Video.iPhoneFixedHeightUnflippableHigh
        let iPadVideoName =
          isObjectFlippable
          ? Video.iPadFixedHeight3 : Video.iPadFixedHeightUnflippableHigh
        return UIDevice.isPad ? iPadVideoName : iPhoneVideoName
      }
    }

    static func < (lhs: AppDataModel.Orbit, rhs: AppDataModel.Orbit) -> Bool {
      guard let lhsIndex = Self.allCases.firstIndex(of: lhs),
        let rhsIndex = Self.allCases.firstIndex(of: rhs)
      else {
        return false
      }
      return lhsIndex < rhsIndex
    }

  }
  
}

extension AppDataModel {
  
  /// A segment can have n orbits. An orbit can reset to go from the capturing state back to it's initial state.
  enum OrbitState {
    
    case initial, capturing
    
  }
  
}

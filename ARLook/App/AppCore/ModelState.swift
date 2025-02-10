//
//  ModelState.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//

extension AppDataModel {

  enum ModelState: String, CustomStringConvertible {
    
    case notSet
    case ready
    case capturing
    case prepareToReconstruct
    case reconstructing
    case viewing
    case completed
    case restart
    case failed

    var description: String { rawValue }

  }

}

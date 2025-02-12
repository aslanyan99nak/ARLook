//
//  ProcessingStage+Ext.swift
//  ARLook
//
//  Created by Narek Aslanyan on 07.02.25.
//

import RealityKit

extension PhotogrammetrySession.Output.ProcessingStage {
  
  var processingStageString: String? {
    switch self {
    case .preProcessing: String.LocString.preProcessing
    case .imageAlignment: String.LocString.imageAlignment
    case .pointCloudGeneration: String.LocString.pointCloudGeneration
    case .meshGeneration: String.LocString.meshGeneration
    case .textureMapping: String.LocString.textureMapping
    case .optimization: String.LocString.optimization
    default: nil
    }
  }
  
}

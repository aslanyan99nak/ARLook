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
    case .preProcessing: LocString.preProcessing
    case .imageAlignment: LocString.imageAlignment
    case .pointCloudGeneration: LocString.pointCloudGeneration
    case .meshGeneration: LocString.meshGeneration
    case .textureMapping: LocString.textureMapping
    case .optimization: LocString.optimization
    default: nil
    }
  }
  
}

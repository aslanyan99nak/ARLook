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
    case .preProcessing: "Pre-Processing…"
    case .imageAlignment: "Aligning Images…"
    case .pointCloudGeneration: "Generating Point Cloud…"
    case .meshGeneration: "Generating Mesh…"
    case .textureMapping: "Mapping Texture…"
    case .optimization: "Optimizing…"
    default: nil
    }
  }
  
}

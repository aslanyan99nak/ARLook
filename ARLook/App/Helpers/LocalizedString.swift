//
//  LocalizedString.swift
//  ARLook
//
//  Created by Narek Aslanyan on 06.02.25.
//


import Foundation

extension String {
  
  enum LocalizedString {
    
    static let `continue` = "Continue"
    static let finish = "Finish"
    static let skip = "Skip"
    static let cannotFlipYourObject = "Can't flip your object?"
    static let flipAnyway = "Flip object anyway"
    static let cancel = "Cancel"
    static let startCapture = "Start Capture"
    static let resetBox = "Reset Box"
    static let next = "Next"
    static let numOfImages = "%d/%d"
    static let help = "Help"
    static let processing = "Processing…"
    static let processingModelDescription = "Keep app running while processing."
    static let estimatedRemainingTime = "Estimated time remaining: %@"
    static let calculating = "Calculating…"
    static let tooFewImagesTitle = "Keep moving around your object."
    static let tooFewImagesDetailText = "You need at least %d images of your object to create a model."
    static let firstSegmentNeedsWorkTitle = "Keep going to complete the first segment."
    static let firstSegmentNeedsWorkDetailText = """
        For best quality, capture three segments.
        Tap Skip if you can't make it all the way around, but your final model may have missing areas.
        """
    static let firstSegmentCompleteTitle = "First segment complete."
    static let firstSegmentCompleteDetailText = "For best quality, caputure three segments."
    static let flipObjectTitle = "Flip object on its side and capture again."
    static let flipObjectDetailText = "Make sure that areas you captured previously can still be seen. Avoid flipping your object if it changes the shape."
    static let flippingObjectNotRecommendedTitle = "Flipping this object is not recommended."
    static let flippingObjectNotRecommendedDetailText = """
        Your object may have single color surfaces or be too reflective to add more segments.
        Tap Continue to capture more detail without flipping, or Flip Object Anyway.
        """
    static let captureFromLowerAngleTitle = "Capture your object again from a lower angle."
    static let captureFromLowerAngleDetailText = "Move down to be level with the base of your object and capture again."
    static let secondSegmentNeedsWorkTitle = "Keep going to complete the second segment."
    static let secondSegmentNeedsWorkDetailText = """
        For best quality, capture three segments.
        Tap Skip if you can't make it all the way around but your final model may have missing areas.
        """
    static let secondSegmentCompleteTitle = "Second segment complete."
    static let secondSegmentCompleteDetailText = "For best quality, capture three segments."
    static let flipObjectASecondTimeTitle = "Flip object on the opposite side and capture again"
    static let flipObjectASecondTimeDetailText = "Make sure that areas you captured previously can still be seen. Avoid flipping your object if it changes the shape."
    static let captureFromHigherAngleTitle = "Capture your object again from a higher angle."
    static let captureFromHigherAngleDetailText = "Move above your object and make sure that areas you captured previously can still be seen."
    static let thirdSegmentNeedsWorkTitle = "Keep going to complete the final segment."
    static let thirdSegmentNeedsWorkDetailText = "For best quality, capture three segments. When you're done, tap Finish to complete your object."
    static let thirdSegmentCompleteTitle = "All segments complete."
    static let thirdSegmentCompleteDetailText = "Tap Finish to process your object."
    static let segment1FeedbackString = "Move slowly around your object."
    static let segment2And3FlippableFeedbackString = "Flip object on its side and move around."
    static let segment2UnflippableFeedbackString = "Move low and capture again."
    static let segment3UnflippableFeedbackString = "Move above your object and capture again."
    static let processingTitle = "Processing"
    static let detectionFailedGuidance = "Can‘t find your object. It should be larger than 3in (8cm) in each dimension."
    static let detectionSuccessedGuidance = "Move close and center the dot on your object, then tap Continue."
    static let detectionGuidance = "Move around to ensure that the whole object is inside the box. Drag handles to manually resize."
    static let environmentHelpCaption =
      "Make sure you have even, good lighting and a stable environment for scanning.  If scanning outdoors, cloudy days work best.\n"
    static let objectHelpCaption = "Opaque, matte objects with varied surface textures scan best. Capture all sides of your object in a series of orbits.\n"
    
    static let objectTooFar = "Move Closer"
    static let objectTooClose = "Move Farther Away"
    static let environmentLightRequired = "More Light Required"
    static let movingTooFast = "Move slower"
    static let outOfFieldOfView = "Aim at your object"
    
    static let objectHelpPageName = "Capturing Objects"
    static let objectProsTitle = "Ideal Object Characteristics"
    static let objectPros1 = "Varied Surface Texture"
    static let objectPros2 = "Non-reflective, matte surface"
    static let objectPros3 = "Solid, opaque"
    static let objectConsTitle = "May Reduce Quality"
    static let objectCons1 = "Shiny materials"
    static let objectCons2 = "Transparent, transluscent objects"
    
    static let envHelpPageName = "Environment"
    static let envProsTitle = "Ideal Environment Characteristics"
    static let envPros1 = "Diffuse, consistent lighting"
    static let envPros2 = "Space around intended object"
    static let envPros3 = " "
    static let envConsTitle = "May Reduce Quality"
    static let envCons1 = "Sunny, directional lighting"
    static let envCons2 = "Inconsistent shadows"
    
  }

}

//
//  VisionTask.swift
//  
//
//  Created by Vasilis Akoinoglou on 4/7/23.
//

import Foundation

public enum VisionTaskType: CaseIterable, Identifiable {

    public var id: Self { self }

    // 1st GEN
    case horizonDetection,
         faceDetection,
         faceLandmarkDetection,
         humanRectanglesDetection,
         rectanglesDetection,
         barcodeDetection,
         textRectanglesDetection,
         animalDetection,
         attentionSaliency,
         objectnessSaliency,
         faceCaptureQuality,
         translationalImageRegistration,
         homographicImageRegistration,
         textRecognition,
         featurePrintGeneration,
         rectangleTracking,
         objectTracking,
         imageClassification

    // 2nd GEN
    @available(iOS 14.0, macCatalyst 14.0, macOS 11.0, tvOS 14.0, *)
    case humanBodyPoseDetection,
         humanHandPoseDetection,
         contoursDetection,
         trajectoriesDetection,
         opticalFlowGeneration

    // 3rd GEN
    @available(iOS 15.0, macCatalyst 15.0, macOS 12.0, tvOS 15.0, *)
    case personSegmentation,
         documentSegmentation

    // 4th GEN
    @available(iOS 17.0, macCatalyst 17.0, macOS 14.0, tvOS 17.0, *)
    case animalBodyPoseDetection,
         humanBodyPoseDetection3D,
         opticalFlowTracking,
         translationalImageRegistrationTracking,
         homographicImageRegistrationTracking,
         foregroundInstanceMaskGeneration

    //MARK: - Custom CoreMLModel
    case customClassification,
         customImageToImage,
         customRecognition,
         customGeneric


    /*----------------------------------------------------------------------------------------------------------------*/

    //MARK: - CaseIterable
    public static var allCases: [VisionTaskType] = {
        var tasks: [VisionTaskType] = [
            .horizonDetection,
            .attentionSaliency,
            .objectnessSaliency,
            .faceDetection,
            .faceLandmarkDetection,
            .faceCaptureQuality,
            .humanRectanglesDetection,
            .rectanglesDetection,
            .rectangleTracking,
            .objectTracking,
            .animalDetection,
            .imageClassification,
            .barcodeDetection,
            .textRectanglesDetection,
            .textRecognition,
            .featurePrintGeneration,
            .translationalImageRegistration,
            .homographicImageRegistration,
            .customClassification,
            .customImageToImage,
            .customRecognition,
            .customGeneric
        ]

        if #available(iOS 14.0, macCatalyst 14.0, macOS 11.0, tvOS 14.0, *) {
            tasks.append(contentsOf: [
                .humanBodyPoseDetection,
                .humanHandPoseDetection,
                .opticalFlowGeneration,
                .contoursDetection,
                .trajectoriesDetection
            ])
        }

        if #available(iOS 15.0, macCatalyst 15.0, macOS 12.0, tvOS 15.0, *) {
            tasks.append(contentsOf: [
                .personSegmentation,
                .documentSegmentation
            ])
        }

        if #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, tvOS 17.0, *) {
            tasks.append(contentsOf: [
                .animalBodyPoseDetection,
                .humanBodyPoseDetection3D,
                .opticalFlowTracking,
                .translationalImageRegistrationTracking,
                .homographicImageRegistrationTracking,
                .foregroundInstanceMaskGeneration
            ])
        }

        return tasks
    }()

    //MARK: - Description
    public var title: String {
        switch self {
        case .horizonDetection:
            return "Horizon Detection"
        case .attentionSaliency:
            return "Attention Saliency"
        case .objectnessSaliency:
            return "Objectness Saliency"
        case .faceDetection:
            return "Face Detection"
        case .faceLandmarkDetection:
            return "Face Landmark Detection"
        case .faceCaptureQuality:
            return "Face Capture Quality"
        case .humanRectanglesDetection:
            return "Human Rectangles Detection"
        case .personSegmentation:
            return "Person Segmentation"
        case .documentSegmentation:
            return "Document Segmentation"
        case .rectanglesDetection:
            return "Rectangles Detection"
        case .humanBodyPoseDetection:
            return "Human Body Pose Detection"
        case .humanHandPoseDetection:
            return "Human Hand Pose Detection"
        case .rectangleTracking:
            return "Rectangle Tracking"
        case .objectTracking:
            return "Object Tracking"
        case .animalDetection:
            return "Animal Detection"
        case .imageClassification:
            return "Classify Image"
        case .featurePrintGeneration:
            return "Feature Print Generation"
        case .opticalFlowGeneration:
            return "Optical Flow Generation"
        case .contoursDetection:
            return "Contours Detection"
        case .trajectoriesDetection:
            return "Trajectories Detection"
        case .barcodeDetection:
            return "Barcode Detection"
        case .textRectanglesDetection:
            return "Text Rectangles Detection"
        case .textRecognition:
            return "Text Recognition"
        case .homographicImageRegistration:
            return "Homographic Image Registration"
        case .translationalImageRegistration:
            return "Translational Image Registration"
        case .customClassification:
            return "Custom Classification CoreML Model"
        case .customImageToImage:
            return "Custom Image-To-Image CoreML Model"
        case .customRecognition:
            return "Custom Object Recognition CoreML Model"
        case .customGeneric:
            return "Custom CoreML Model"
        case .animalBodyPoseDetection:
            return "Animal Body Pose Detection"
        case .humanBodyPoseDetection3D:
            return "Human Body Pose Detection (3D)"
        case .opticalFlowTracking:
            return "Optical Flow Tracking"
        case .translationalImageRegistrationTracking:
            return "Translational Image Registration Tracking"
        case .homographicImageRegistrationTracking:
            return "Homographic Image Registration Tracking"
        case .foregroundInstanceMaskGeneration:
            return "Foreground Instance Mask Generation"
        }
    }

}

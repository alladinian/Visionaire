//
//  VisionTask.swift
//  
//
//  Created by Vasilis Akoinoglou on 4/7/23.
//

import Foundation

public enum VisionTaskType: CaseIterable, Identifiable {

    public var id: Self { self }

    //MARK: - Detection
    case horizonDetection,
         faceDetection,
         faceLandmarkDetection,
         humanRectanglesDetection,
         rectanglesDetection,
         barcodeDetection,
         textRectanglesDetection,
         animalDetection

    @available(iOS 14.0, macOS 11.0, *)
    case humanBodyPoseDetection,
         humanHandPoseDetection,
         contoursDetection

    @available(iOS 17.0, macOS 14.0, *)
    case animalBodyPoseDetection

    //MARK: - Saliency
    case attentionSaliency,
         objectnessSaliency

    //MARK: - Misc
    case faceCaptureQuality

    @available(iOS 14.0, macOS 11.0, *)
    case opticalFlow

    //MARK: - Tracking
    case rectanglesTracking,
         objectTracking

    //MARK: - Classification
    case imageClassification

    //MARK: - Segmentation
    @available(iOS 15.0, macOS 12.0, *)
    case personSegmentation,
         documentSegmentation

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
            .rectanglesTracking,
            .objectTracking,
            .animalDetection,
            .imageClassification,
            .barcodeDetection,
            .textRectanglesDetection
        ]

        if #available(iOS 14.0, macOS 11.0, *) {
            tasks.append(contentsOf: [
                .humanBodyPoseDetection,
                .humanHandPoseDetection,
                .opticalFlow,
                .contoursDetection
            ])
        }

        if #available(iOS 15.0, macOS 12.0, *) {
            tasks.append(contentsOf: [
                .personSegmentation,
                .documentSegmentation
            ])
        }

        if #available(iOS 17.0, macOS 14.0, *) {
            tasks.append(contentsOf: [
                .animalBodyPoseDetection
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
        case .rectanglesTracking:
            return "Rectangles Tracking"
        case .objectTracking:
            return "Object Tracking"
        case .animalDetection:
            return "Animal Detection"
        case .imageClassification:
            return "Classify Image"
        case .opticalFlow:
            return "Optical Flow"
        case .contoursDetection:
            return "Contours Detection"
        case .animalBodyPoseDetection:
            return "Animal Body Pose Detection"
        case .barcodeDetection:
            return "Barcode Detection"
        case .textRectanglesDetection:
            return "Text Rectangles Detection"
        }
    }

}

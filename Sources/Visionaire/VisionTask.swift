//
//  VisionTask.swift
//  
//
//  Created by Vasilis Akoinoglou on 4/7/23.
//

import Foundation
import Vision

public enum VisionTaskType: CaseIterable, Identifiable {

    public var id: VisionTaskType { self }

    case horizonDetection,
         attentionSaliency,
         objectnessSaliency,
         faceDetection,
         faceLandmarkDetection,
         faceCaptureQuality,
         humanRectanglesDetection,
         rectanglesDetection

    @available(iOS 14.0, macOS 11.0, *)
    case humanBodyPoseDetection
    
    @available(iOS 15.0, macOS 12.0, *)
    case personSegmentation,
         documentSegmentation
    
    public static var allCases: [VisionTaskType] = {
        var tasks: [VisionTaskType] = [.horizonDetection, .attentionSaliency, .objectnessSaliency, .faceDetection, .faceLandmarkDetection, .faceCaptureQuality, .humanRectanglesDetection, .rectanglesDetection]

        if #available(iOS 14.0, macOS 11.0, *) {
            tasks.append(contentsOf: [.humanBodyPoseDetection])
        }

        if #available(iOS 15.0, macOS 12.0, *) {
            tasks.append(contentsOf: [.personSegmentation, .documentSegmentation])
        }

        return tasks
    }()
    
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
        }
    }
    
}

public struct VisionTask: Identifiable {

    public let id = UUID()

    public let taskType: VisionTaskType
    
    public var title: String {
        taskType.title
    }

    public let request: VNRequest
    
    private init(taskType: VisionTaskType, request: VNRequest) {
        self.taskType = taskType
        self.request = request
    }

    public func cancel() {
        request.cancel()
    }

    public func preferBackgroundProcessing(_ preferBackgroundProcessing: Bool) -> VisionTask {
        request.preferBackgroundProcessing = preferBackgroundProcessing
        return self
    }

    public func usesCPUOnly(_ usesCPUOnly: Bool) -> VisionTask {
        request.usesCPUOnly = usesCPUOnly
        return self
    }

    public func revision(_ revision: Int) -> VisionTask {
        if type(of: request).supportedRevisions.contains(revision) {
            request.revision = revision
        }
        return self
    }

    public func regionOfInterest(_ regionOfInterest: CGRect) -> VisionTask {
        (request as? VNImageBasedRequest)?.regionOfInterest = regionOfInterest
        return self
    }

    public static var horizonDetection: VisionTask {
        VisionTask(taskType: .horizonDetection, request: VNDetectHorizonRequest())
    }

    public static var attentionSaliency: VisionTask {
        VisionTask(taskType: .attentionSaliency, request: VNGenerateAttentionBasedSaliencyImageRequest())
    }

    public static var objectnessSaliency: VisionTask {
        VisionTask(taskType: .objectnessSaliency, request: VNGenerateObjectnessBasedSaliencyImageRequest())
    }

    public static var faceDetection: VisionTask {
        VisionTask(taskType: .faceDetection, request: VNDetectFaceRectanglesRequest())
    }

    public static var faceLandmarkDetection: VisionTask {
        VisionTask(taskType: .faceLandmarkDetection, request: VNDetectFaceLandmarksRequest())
    }

    /*----------------------------------------------------------------------------------------------------------------*/

    @available(iOS 15.0, macOS 12.0, *)
    public static func humanRectanglesDetection(upperBodyOnly: Bool) -> VisionTask {
        let request = VNDetectHumanRectanglesRequest()
        request.upperBodyOnly = upperBodyOnly
        return VisionTask(taskType: .humanRectanglesDetection, request: request)
    }

    public static var humanRectanglesDetection: VisionTask {
        VisionTask(taskType: .humanRectanglesDetection, request: VNDetectHumanRectanglesRequest())
    }

    /*----------------------------------------------------------------------------------------------------------------*/
    
    @available(iOS 15.0, macOS 12.0, *)
    public static var personSegmentation: VisionTask {
        VisionTask(taskType: .personSegmentation, request: VNGeneratePersonSegmentationRequest())
    }

    @available(iOS 15.0, macOS 12.0, *)
    public static func personSegmentation(qualityLevel: VNGeneratePersonSegmentationRequest.QualityLevel) -> VisionTask {
        let request = VNGeneratePersonSegmentationRequest()
        request.qualityLevel = qualityLevel
        return VisionTask(taskType: .personSegmentation, request: request)
    }

    /*----------------------------------------------------------------------------------------------------------------*/
    
    public static var faceCaptureQuality: VisionTask {
        VisionTask(taskType: .faceCaptureQuality, request: VNDetectFaceCaptureQualityRequest())
    }

    /*----------------------------------------------------------------------------------------------------------------*/
    
    @available(iOS 15.0, macOS 12.0, *)
    public static var documentSegmentation: VisionTask {
        VisionTask(taskType: .documentSegmentation, request: VNDetectDocumentSegmentationRequest())
    }

    /*----------------------------------------------------------------------------------------------------------------*/

    public static var rectanglesDetection: VisionTask {
        VisionTask(taskType: .rectanglesDetection, request: VNDetectRectanglesRequest())
    }

    public static func rectanglesDetection(minimumAspectRatio: VNAspectRatio? = nil,
                                           maximumAspectRatio: VNAspectRatio? = nil,
                                           quadratureTolerance: VNDegrees? = nil,
                                           minimumSize: Float? = nil,
                                           minimumConfidence: VNConfidence? = nil,
                                           maximumObservations: Int? = nil) -> VisionTask {
        let request = VNDetectRectanglesRequest()

        if let minimumAspectRatio {
            request.minimumAspectRatio = minimumAspectRatio
        }
        if let maximumAspectRatio {
            request.maximumAspectRatio = maximumAspectRatio
        }
        if let quadratureTolerance {
            request.quadratureTolerance = quadratureTolerance
        }
        if let minimumSize {
            request.minimumSize = minimumSize
        }
        if let minimumConfidence {
            request.minimumConfidence = minimumConfidence
        }
        if let maximumObservations {
            request.maximumObservations = maximumObservations
        }

        return VisionTask(taskType: .rectanglesDetection, request: request)
    }

    @available(iOS 14.0, macOS 11.0, *)
    public static var humanBodyPoseDetection: VisionTask {
        VisionTask(taskType: .humanBodyPoseDetection, request: VNDetectHumanBodyPoseRequest())
    }

}

public enum SaliencyMode {
    case attention
    case object

    var task: VisionTask {
        switch self {
        case .attention: return .attentionSaliency
        case .object:    return .objectnessSaliency
        }
    }
}

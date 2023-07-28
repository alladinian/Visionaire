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
         humanRectanglesDetection
    
    @available(iOS 15.0, macOS 12.0, *)
    case personSegmentation,
         documentSegmentation
    
    public static var allCases: [VisionTaskType] = {
        var tasks: [VisionTaskType] = [.horizonDetection, .attentionSaliency, .objectnessSaliency, .faceDetection, .faceLandmarkDetection, .faceCaptureQuality, .humanRectanglesDetection]

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
        }
    }
    
}

public struct VisionTask: Identifiable, Hashable {

    public static func == (lhs: VisionTask, rhs: VisionTask) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public let id = UUID()

    public let taskType: VisionTaskType
    
    public var title: String {
        taskType.title
    }

    let request: VNRequest
    
    private init(taskType: VisionTaskType, request: VNRequest) {
        self.taskType = taskType
        self.request = request
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

//
//  VisionTask.swift
//  
//
//  Created by Vasilis Akoinoglou on 4/7/23.
//

import Foundation
import Vision

public enum VisionTaskType: CaseIterable {
    case horizonDetection,
         attentionSaliency,
         objectnessSaliency,
         faceDetection,
         faceLandmarkDetection,
         faceCaptureQuality
    
    @available(iOS 15.0, macOS 12.0, *)
    case humanRectanglesDetection,
         personSegmentation,
         documentSegmentation
    
    public static var allCases: [VisionTaskType] = {
        var tasks: [VisionTaskType] = [.horizonDetection, .attentionSaliency, .objectnessSaliency, .faceDetection, .faceLandmarkDetection, .faceCaptureQuality]

        if #available(iOS 15.0, macOS 12.0, *) {
            tasks.append(contentsOf: [.humanRectanglesDetection, .personSegmentation, .documentSegmentation])
        }

        return tasks
    }()
    
    var title: String {
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
    
    public var title: String { taskType.title }

    var requestType: VNImageBasedRequest.Type
    var observationType: VNObservation.Type
    
    init(taskType: VisionTaskType) {
        self.taskType = taskType
        
        switch taskType {
        case .horizonDetection:
            requestType     = VNDetectHorizonRequest.self
            observationType = VNHorizonObservation.self
        case .attentionSaliency:
            requestType     = VNGenerateAttentionBasedSaliencyImageRequest.self
            observationType = VNSaliencyImageObservation.self
        case .objectnessSaliency:
            requestType     = VNGenerateObjectnessBasedSaliencyImageRequest.self
            observationType = VNSaliencyImageObservation.self
        case .faceDetection:
            requestType     = VNDetectFaceRectanglesRequest.self
            observationType = VNFaceObservation.self
        case .faceLandmarkDetection:
            requestType     = VNDetectFaceLandmarksRequest.self
            observationType = VNFaceObservation.self
        case .faceCaptureQuality:
            requestType     = VNDetectFaceCaptureQualityRequest.self
            observationType = VNFaceObservation.self
        case .humanRectanglesDetection:
            requestType     = VNDetectHumanRectanglesRequest.self
            observationType = VNHumanObservation.self
        case .personSegmentation:
            requestType     = VNGeneratePersonSegmentationRequest.self
            observationType = VNPixelBufferObservation.self
        case .documentSegmentation:
            requestType     = VNDetectDocumentSegmentationRequest.self
            observationType = VNRectangleObservation.self
        }
    }

    public static var horizonDetection: VisionTask {
        VisionTask(taskType: .horizonDetection)
    }

    public static var attentionSaliency: VisionTask {
        VisionTask(taskType: .attentionSaliency)
    }

    public static var objectnessSaliency: VisionTask {
        VisionTask(taskType: .objectnessSaliency)
    }

    public static var faceDetection: VisionTask {
        VisionTask(taskType: .faceDetection)
    }

    public static var faceLandmarkDetection: VisionTask {
        VisionTask(taskType: .faceLandmarkDetection)
    }

    @available(iOS 15.0, macOS 12.0, *)
    public static var humanRectanglesDetection: VisionTask {
        VisionTask(taskType: .humanRectanglesDetection)
    }
    
    @available(iOS 15.0, macOS 12.0, *)
    public static var personSegmentation: VisionTask {
        VisionTask(taskType: .personSegmentation)
    }
    
    public static var faceCaptureQuality: VisionTask {
        VisionTask(taskType: .faceCaptureQuality)
    }
    
    @available(iOS 15.0, macOS 12.0, *)
    public static var documentSegmentation: VisionTask {
        VisionTask(taskType: .documentSegmentation)
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


extension VisionTask {
    func request(revision: Int? = nil, completion: @escaping (VNRequest, Error?) -> Void) -> VNImageBasedRequest {
        let request = requestType.init() { request, error in

            if let error {
                completion(request, error)
                return
            }

            guard let _ = request.results else {
                completion(request, VisionaireError.noObservations)
                return
            }

            completion(request, nil)
        }

        if let revision, requestType.supportedRevisions.contains(revision) {
            request.revision = revision
        }

        return request
    }
}

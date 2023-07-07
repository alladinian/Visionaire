//
//  VisionTask.swift
//  
//
//  Created by Vasilis Akoinoglou on 4/7/23.
//

import Foundation
import Vision

enum VisionTaskEnum: Int {
    case horizonDetection
    case attentionSaliency
    case objectnessSaliency
    case faceDetection
    case faceLandmarkDetection
    case humanRectanglesDetection
    case faceCaptureQuality
    case personSegmentation
    case documentSegmentation

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
        case .humanRectanglesDetection:
            return "Human Rectangles Detection"
        case .faceCaptureQuality:
            return "Face Capture Quality"
        case .personSegmentation:
            return "Person Segmentation"
        case .documentSegmentation:
            return "Document Segmentation"
        }
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

public struct VisionTask: Hashable {
    public static func == (lhs: VisionTask, rhs: VisionTask) -> Bool {
        lhs.taskEnum == rhs.taskEnum
    }

    public static let horizonDetection         = VisionTask(.horizonDetection)

    public static let attentionSaliency        = VisionTask(.attentionSaliency)
    public static let objectnessSaliency       = VisionTask(.objectnessSaliency)

    public static let faceDetection            = VisionTask(.faceDetection)
    public static let faceLandmarkDetection    = VisionTask(.faceLandmarkDetection)
    public static let faceCaptureQuality       = VisionTask(.faceCaptureQuality)

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
    public static let humanRectanglesDetection =  VisionTask(.humanRectanglesDetection)

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
    public static let personSegmentation       = VisionTask(.personSegmentation)

    public static let documentSegmentation     = VisionTask(.documentSegmentation)

    public static var allSupportedTasks: [VisionTask] {
        var tasks: [VisionTask] = [.horizonDetection, .attentionSaliency, .objectnessSaliency, .faceDetection, .faceLandmarkDetection, .faceCaptureQuality, .documentSegmentation]

        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, *) {
            tasks.append(contentsOf: [.humanRectanglesDetection, .personSegmentation])
        }

        return tasks
    }

    public var title: String { taskEnum.title }

    private let taskEnum: VisionTaskEnum

    init(_ taskEnum: VisionTaskEnum) {
        self.taskEnum = taskEnum
    }

}

extension VisionTask {
    var requestType: VNImageBasedRequest.Type {
        switch taskEnum {
        case .horizonDetection:
            return VNDetectHorizonRequest.self
        case .attentionSaliency:
            return VNGenerateAttentionBasedSaliencyImageRequest.self
        case .objectnessSaliency:
            return VNGenerateObjectnessBasedSaliencyImageRequest.self
        case .faceDetection:
            return VNDetectFaceRectanglesRequest.self
        case .faceLandmarkDetection:
            return VNDetectFaceLandmarksRequest.self
        case .humanRectanglesDetection:
            return VNDetectHumanRectanglesRequest.self
        case .faceCaptureQuality:
            return VNDetectFaceCaptureQualityRequest.self
        case .personSegmentation:
            if #available(iOS 15.0, macOS 12.0, tvOS 13.0, *) {
                return VNGeneratePersonSegmentationRequest.self
            } else {
                return VNImageBasedRequest.self
            }
        case .documentSegmentation:
            if #available(iOS 15.0, macOS 12.0, tvOS 13.0, *) {
                return VNDetectDocumentSegmentationRequest.self
            } else {
                return VNImageBasedRequest.self
            }
        }
    }

    var observationType: VNObservation.Type {
        switch taskEnum {
        case .horizonDetection:
            return VNHorizonObservation.self
        case .attentionSaliency, .objectnessSaliency:
            return VNSaliencyImageObservation.self
        case .faceDetection, .faceLandmarkDetection, .faceCaptureQuality:
            return VNFaceObservation.self
        case .humanRectanglesDetection:
            if #available(iOS 15.0, macOS 12.0, tvOS 13.0, *) {
                return VNHumanObservation.self
            } else {
                return VNObservation.self
            }

        case .personSegmentation:
            if #available(iOS 15.0, macOS 12.0, tvOS 13.0, *) {
                return VNPixelBufferObservation.self
            } else {
                return VNObservation.self
            }

        case .documentSegmentation:
            return VNRectangleObservation.self
        }
    }
}


extension VisionTask {
    func request(revision: Int? = nil, completion: @escaping (VNRequest, Error?) -> Void) -> some VNImageBasedRequest {
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

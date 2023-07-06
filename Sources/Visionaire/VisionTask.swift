//
//  VisionTask.swift
//  
//
//  Created by Vasilis Akoinoglou on 4/7/23.
//

import Foundation
import Vision

enum VisionTaskEnum {
    case horizonDetection
    case saliency(mode: SaliencyMode)
    case faceDetection
    case faceLandmarkDetection
    case humanRectanglesDetection
    case faceCaptureQuality
    case personSegmentation
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

public struct VisionTask {
    static let horizonDetection         = VisionTask(.horizonDetection)

    static let attentionSaliency        = VisionTask(.saliency(mode: .attention))
    static let objectnessSaliency       = VisionTask(.saliency(mode: .object))

    static let faceDetection            = VisionTask(.faceDetection)
    static let faceLandmarkDetection    = VisionTask(.faceLandmarkDetection)
    static let faceCaptureQuality       = VisionTask(.faceCaptureQuality)

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
    static let humanRectanglesDetection =  VisionTask(.humanRectanglesDetection)

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
    static let personSegmentation       = VisionTask(.personSegmentation)

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
        case .saliency(let mode):
            switch mode {
            case .attention: return VNGenerateAttentionBasedSaliencyImageRequest.self
            case .object:    return VNGenerateObjectnessBasedSaliencyImageRequest.self
            }
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
        }
    }

    var observationType: VNObservation.Type {
        switch taskEnum {
        case .horizonDetection:
            return VNHorizonObservation.self
        case .saliency:
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

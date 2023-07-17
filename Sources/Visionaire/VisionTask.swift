//
//  VisionTask.swift
//  
//
//  Created by Vasilis Akoinoglou on 4/7/23.
//

import Foundation
import Vision

public struct VisionTask: Identifiable, Hashable {

    public static func == (lhs: VisionTask, rhs: VisionTask) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public let id = UUID()

    public static var allCases: [VisionTask] {
        var tasks: [VisionTask] = [.horizonDetection, .attentionSaliency, .objectnessSaliency, .faceDetection, .faceLandmarkDetection, .faceCaptureQuality]

        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, *) {
            tasks.append(contentsOf: [.humanRectanglesDetection, .personSegmentation, .documentSegmentation])
        }

        return tasks
    }

    public static let horizonDetection         = VisionTask(title: "Horizon Detection",
                                                            requestType: VNDetectHorizonRequest.self,
                                                            observationType: VNHorizonObservation.self)

    public static let attentionSaliency        = VisionTask(title: "Attention Saliency",
                                                            requestType: VNGenerateAttentionBasedSaliencyImageRequest.self,
                                                            observationType: VNSaliencyImageObservation.self)

    public static let objectnessSaliency       = VisionTask(title: "Objectness Saliency",
                                                            requestType: VNGenerateObjectnessBasedSaliencyImageRequest.self,
                                                            observationType: VNSaliencyImageObservation.self)

    public static let faceDetection            = VisionTask(title: "Face Detection",
                                                            requestType: VNDetectFaceRectanglesRequest.self,
                                                            observationType: VNFaceObservation.self)

    public static let faceLandmarkDetection    = VisionTask(title: "Face Landmark Detection",
                                                            requestType: VNDetectFaceLandmarksRequest.self,
                                                            observationType: VNFaceObservation.self)


    @available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
    public static let humanRectanglesDetection = VisionTask(title: "Human Rectangles Detection",
                                                            requestType: VNDetectHumanRectanglesRequest.self,
                                                            observationType: VNHumanObservation.self)

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
    public static let personSegmentation       = VisionTask(title: "Person Segmentation",
                                                            requestType: VNGeneratePersonSegmentationRequest.self,
                                                            observationType: VNPixelBufferObservation.self)

    public static let faceCaptureQuality       = VisionTask(title: "Face Capture Quality",
                                                            requestType: VNDetectFaceCaptureQualityRequest.self,
                                                            observationType: VNFaceObservation.self)

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
    public static let documentSegmentation     = VisionTask(title: "Document Segmentation",
                                                            requestType: VNDetectDocumentSegmentationRequest.self,
                                                            observationType: VNRectangleObservation.self)

    public var title: String

    var requestType: VNImageBasedRequest.Type
    var observationType: VNObservation.Type
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

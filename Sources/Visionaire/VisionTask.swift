//
//  VisionTask.swift
//  
//
//  Created by Vasilis Akoinoglou on 4/7/23.
//

import Foundation
import Vision

public struct VisionTask: Identifiable {

    public let id = UUID()

    public let taskType: VisionTaskType
    
    public var title: String {
        taskType.title
    }

    public let request: VNImageBasedRequest

    private init(taskType: VisionTaskType, request: VNImageBasedRequest) {
        self.taskType = taskType
        self.request = request
    }

    public func cancel() {
        request.cancel()
    }

    //MARK: - General Options

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

    public func latestRevision() -> VisionTask {
        if let last = type(of: request).supportedRevisions.last {
            request.revision = last
        }
        return self
    }

    public func regionOfInterest(_ regionOfInterest: CGRect) -> VisionTask {
        request.regionOfInterest = regionOfInterest
        return self
    }

    //MARK: - Horizon Detection

    public static var horizonDetection: VisionTask {
        VisionTask(taskType: .horizonDetection, request: VNDetectHorizonRequest())
    }

    //MARK: - Saliency

    public static var attentionSaliency: VisionTask {
        VisionTask(taskType: .attentionSaliency, request: VNGenerateAttentionBasedSaliencyImageRequest())
    }

    public static var objectnessSaliency: VisionTask {
        VisionTask(taskType: .objectnessSaliency, request: VNGenerateObjectnessBasedSaliencyImageRequest())
    }

    //MARK: - Face Detection

    public static var faceDetection: VisionTask {
        VisionTask(taskType: .faceDetection, request: VNDetectFaceRectanglesRequest())
    }

    //MARK: - Face Landmark Detection

    public static var faceLandmarkDetection: VisionTask {
        VisionTask(taskType: .faceLandmarkDetection, request: VNDetectFaceLandmarksRequest())
    }

    //MARK: - Human Rectangles Detection

    public static var humanRectanglesDetection: VisionTask {
        VisionTask(taskType: .humanRectanglesDetection, request: VNDetectHumanRectanglesRequest())
    }

    @available(iOS 15.0, macOS 12.0, *)
    public static func humanRectanglesDetection(upperBodyOnly: Bool) -> VisionTask {
        let request           = VNDetectHumanRectanglesRequest()
        request.upperBodyOnly = upperBodyOnly
        return VisionTask(taskType: .humanRectanglesDetection, request: request)
    }

    //MARK: - Person Segmentation
    
    @available(iOS 15.0, macOS 12.0, *)
    public static var personSegmentation: VisionTask {
        VisionTask(taskType: .personSegmentation, request: VNGeneratePersonSegmentationRequest())
    }

    @available(iOS 15.0, macOS 12.0, *)
    public static func personSegmentation(qualityLevel: VNGeneratePersonSegmentationRequest.QualityLevel? = nil,
                                          outputPixelFormat: OSType? = nil) -> VisionTask {
        let request = VNGeneratePersonSegmentationRequest()
        if let qualityLevel {
            request.qualityLevel = qualityLevel
        }
        if let outputPixelFormat {
            request.outputPixelFormat = outputPixelFormat
        }
        return VisionTask(taskType: .personSegmentation, request: request)
    }

    //MARK: - Face Capture Quality
    
    public static var faceCaptureQuality: VisionTask {
        VisionTask(taskType: .faceCaptureQuality, request: VNDetectFaceCaptureQualityRequest())
    }

    //MARK: - Document Segmentation
    
    @available(iOS 15.0, macOS 12.0, *)
    public static var documentSegmentation: VisionTask {
        VisionTask(taskType: .documentSegmentation, request: VNDetectDocumentSegmentationRequest())
    }

    //MARK: - Rectangles Detection

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

    //MARK: - Human Body Detection

    @available(iOS 14.0, macOS 11.0, *)
    public static var humanBodyPoseDetection: VisionTask {
        VisionTask(taskType: .humanBodyPoseDetection, request: VNDetectHumanBodyPoseRequest())
    }

    //MARK: - Human Hand Pose Detection

    @available(iOS 14.0, macOS 11.0, *)
    public static var humanHandPoseDetection: VisionTask {
        VisionTask(taskType: .humanHandPoseDetection, request: VNDetectHumanHandPoseRequest())
    }

    @available(iOS 14.0, macOS 11.0, *)
    public static func humanHandPoseDetection(maximumHandCount: Int) -> VisionTask {
        let request              = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = maximumHandCount
        return VisionTask(taskType: .humanHandPoseDetection, request: request)
    }

    //MARK: - Rectangles Tracking

    public static func rectanglesTracking(observation: VNRectangleObservation,
                                          trackingLevel: VNRequestTrackingLevel? = nil,
                                          isLastFrame: Bool? = nil) -> VisionTask {
        let request = VNTrackRectangleRequest(rectangleObservation: observation)
        if let trackingLevel {
            request.trackingLevel = trackingLevel
        }
        if let isLastFrame {
            request.isLastFrame = isLastFrame
        }
        return VisionTask(taskType: .rectanglesTracking, request: request)
    }

    //MARK: - Object Tracking

    public static func objectTracking(observation: VNDetectedObjectObservation,
                                      trackingLevel: VNRequestTrackingLevel? = nil,
                                      isLastFrame: Bool? = nil) -> VisionTask {
        let request = VNTrackObjectRequest(detectedObjectObservation: observation)
        if let trackingLevel {
            request.trackingLevel = trackingLevel
        }
        if let isLastFrame {
            request.isLastFrame = isLastFrame
        }
        return VisionTask(taskType: .rectanglesTracking, request: request)
    }

    //MARK: - Animal Detection

    public static var animalDetection: VisionTask {
        VisionTask(taskType: .animalDetection, request: VNRecognizeAnimalsRequest())
    }

    //MARK: - Image Classification

    public static var imageClassification: VisionTask {
        VisionTask(taskType: .imageClassification, request: VNClassifyImageRequest())
    }

    //MARK: - Optical Flow

    @available(iOS 14.0, macOS 11.0, *)
    public static func opticalFlow(targetedImage: VisionImageSource,
                                   computationAccuracy: VNGenerateOpticalFlowRequest.ComputationAccuracy? = nil,
                                   outputPixelFormat: OSType? = nil) -> VisionTask {
        let request: VNGenerateOpticalFlowRequest = targetedImage.VNTargetedImageRequest(orientation: nil, context: nil)
        if let computationAccuracy {
            request.computationAccuracy = computationAccuracy
        }
        if let outputPixelFormat {
            request.outputPixelFormat = outputPixelFormat
        }
        return VisionTask(taskType: .opticalFlow, request: request)
    }

    @available(iOS 16.0, macOS 13.0, *)
    public static func opticalFlow(targetedImage: VisionImageSource,
                                   computationAccuracy: VNGenerateOpticalFlowRequest.ComputationAccuracy? = nil,
                                   outputPixelFormat: OSType? = nil,
                                   keepNetworkOutput: Bool? = nil) -> VisionTask {
        let request: VNGenerateOpticalFlowRequest = targetedImage.VNTargetedImageRequest(orientation: nil, context: nil)
        if let computationAccuracy {
            request.computationAccuracy = computationAccuracy
        }
        if let outputPixelFormat {
            request.outputPixelFormat = outputPixelFormat
        }
        if let keepNetworkOutput {
            request.keepNetworkOutput = keepNetworkOutput
        }
        return VisionTask(taskType: .opticalFlow, request: request)
    }

    //MARK: - Contours
    @available(iOS 14.0, macOS 11.0, *)
    public static var contoursDetection: VisionTask {
        VisionTask(taskType: .contoursDetection, request: VNDetectContoursRequest())
    }

    @available(iOS 14.0, macOS 11.0, *)
    public static func contoursDetection(contrastAdjustment: Float? = nil,
                                         detectsDarkOnLight: Bool? = nil,
                                         maximumImageDimension: Int? = nil) -> VisionTask {
        let request = VNDetectContoursRequest()
        if let contrastAdjustment {
            request.contrastAdjustment = contrastAdjustment
        }
        if let detectsDarkOnLight {
            request.detectsDarkOnLight = detectsDarkOnLight
        }
        if let maximumImageDimension {
            request.maximumImageDimension = maximumImageDimension
        }
        return VisionTask(taskType: .contoursDetection, request: request)
    }

    @available(iOS 15.0, macOS 12.0, *)
    public static func contoursDetection(contrastAdjustment: Float? = nil,
                                         contrastPivot: NSNumber? = nil,
                                         detectsDarkOnLight: Bool? = nil,
                                         maximumImageDimension: Int? = nil) -> VisionTask {
        let request = VNDetectContoursRequest()
        if let contrastAdjustment {
            request.contrastAdjustment = contrastAdjustment
        }
        if let contrastPivot {
            request.contrastPivot = contrastPivot
        }
        if let detectsDarkOnLight {
            request.detectsDarkOnLight = detectsDarkOnLight
        }
        if let maximumImageDimension {
            request.maximumImageDimension = maximumImageDimension
        }
        return VisionTask(taskType: .contoursDetection, request: request)
    }

}

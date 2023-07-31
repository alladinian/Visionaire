import Vision
import CoreImage

let kVisionaireContext: CIContext = CIContext(options: [.name: "VisionaireCIContext"])

public final class Visionaire: ObservableObject {

    public static let shared = Visionaire()

    public init() {

    }

    @Published public var isProcessing: Bool = false

    public func warmup(tasks: [VisionTask]) {
        let smallRect  = CGRect(x: 0, y: 0, width: 64, height: 64)
        let solidImage = CIImage(color: .red).cropped(to: smallRect)
        Task {
            do {
                let _ = try perform(tasks, on: solidImage)
                debugPrint("[Visionaire] Warmed up...")
            } catch {
                debugPrint(error)
            }
        }
    }
}

//MARK: - Request Execution
extension Visionaire {
    //MARK: Multiple Requests
    public func perform(_ requests: [VNRequest],
                        ciContext context: CIContext? = nil,
                        on imageSource: VisionImageSource,
                        orientation: CGImagePropertyOrientation? = nil) throws -> [VisionTaskResult] {
        try imageSource.VNImageHandler(orientation: orientation, context: context).perform(requests)
        return requests.map(VisionTaskResult.init)
    }

    //MARK: Single Request
    public func perform(_ request: VNRequest,
                        ciContext context: CIContext? = nil,
                        on imageSource: VisionImageSource,
                        orientation: CGImagePropertyOrientation? = nil) throws -> VisionTaskResult {
        guard let result = try perform([request], ciContext: context, on: imageSource, orientation: orientation).first else {
            throw VisionaireError.noResult
        }
        return result
    }
}

//MARK: - Task Execution
extension Visionaire {
    //MARK: Multiple tasks
    public func perform(_ tasks: [VisionTask],
                        ciContext context: CIContext? = nil,
                        on imageSource: VisionImageSource,
                        orientation: CGImagePropertyOrientation? = nil) throws -> [VisionTaskResult] {
        try perform(tasks.map(\.request), ciContext: context, on: imageSource, orientation: orientation)
    }

    //MARK: Single Task
    public func perform(_ task: VisionTask,
                        ciContext context: CIContext? = nil,
                        on imageSource: VisionImageSource,
                        orientation: CGImagePropertyOrientation? = nil) throws -> VisionTaskResult {
        guard let result = try perform([task], ciContext: context, on: imageSource, orientation: orientation).first else {
            throw VisionaireError.noResult
        }
        return result
    }
}

//MARK: - Observation Casting

extension Visionaire {
    private func multiObservationHandler<T>(_ task: VisionTask, imageSource: VisionImageSource) throws -> [T] {
        let result = try perform(task, on: imageSource)
        return result.observations.compactMap { $0 as? T }
    }

    private func singleObservationHandler<T>(_ task: VisionTask, imageSource: VisionImageSource) throws -> T {
        let result = try perform(task, on: imageSource)
        guard let observation = result.observations.first, let first = observation as? T else {
            throw VisionaireError.noObservations
        }
        return first
    }
}

//MARK: - Convenience Methods (Observation Based)

extension Visionaire {

    public func horizonDetection(imageSource: VisionImageSource) throws -> VNHorizonObservation {
        try singleObservationHandler(.horizonDetection, imageSource: imageSource)
    }

    public func saliencyAnalysis(mode: SaliencyMode, imageSource: VisionImageSource) throws -> [VNSaliencyImageObservation] {
        try multiObservationHandler(mode.task, imageSource: imageSource)
    }

    public func saliencyAnalysis(mode: SaliencyMode, imageSource: VisionImageSource) throws -> [VNRectangleObservation] {
        let saliency: [VNSaliencyImageObservation] = try multiObservationHandler(mode.task, imageSource: imageSource)
        return saliency.flatMap { $0.salientObjects ?? [] }
    }

    public func faceDetection(imageSource: VisionImageSource, regionOfInterest: CGRect? = nil, revision: Int? = nil) throws -> [VNFaceObservation] {
        try multiObservationHandler(.faceDetection, imageSource: imageSource)
    }

    public func faceLandmarkDetection(imageSource: VisionImageSource, regionOfInterest: CGRect? = nil, revision: Int? = nil) throws -> [VNFaceObservation] {
        try multiObservationHandler(.faceLandmarkDetection, imageSource: imageSource)
    }

    public func faceCaptureQualityDetection(imageSource: VisionImageSource, regionOfInterest: CGRect? = nil, revision: Int? = nil) throws -> [VNFaceObservation] {
        try multiObservationHandler(.faceCaptureQuality, imageSource: imageSource)
    }

    @available(iOS 15.0, macOS 12.0, *)
    public func personSegmentation(imageSource: VisionImageSource) throws -> [VNPixelBufferObservation] {
        try multiObservationHandler(.personSegmentation, imageSource: imageSource)
    }

    @available(iOS 15.0, macOS 12.0, *)
    public func personSegmentation(imageSource: VisionImageSource, qualityLevel: VNGeneratePersonSegmentationRequest.QualityLevel) throws -> [VNPixelBufferObservation] {
        try multiObservationHandler(.personSegmentation(qualityLevel: qualityLevel), imageSource: imageSource)
    }

    @available(iOS 15.0, macOS 12.0, *)
    public func documentSegmentation(imageSource: VisionImageSource) throws -> [VNRectangleObservation] {
        try multiObservationHandler(.documentSegmentation, imageSource: imageSource)
    }

    @available(iOS 15.0, macOS 12.0, *)
    public func humanRectanglesDetection(imageSource: VisionImageSource) throws -> [VNHumanObservation] {
        try multiObservationHandler(.humanRectanglesDetection, imageSource: imageSource)
    }

    public func rectanglesDetection(imageSource: VisionImageSource,
                                    minimumAspectRatio: VNAspectRatio? = nil,
                                    maximumAspectRatio: VNAspectRatio? = nil,
                                    quadratureTolerance: VNDegrees? = nil,
                                    minimumSize: Float? = nil,
                                    minimumConfidence: VNConfidence? = nil,
                                    maximumObservations: Int? = nil) throws -> [VNRectangleObservation] {
        try multiObservationHandler(.rectanglesDetection(minimumAspectRatio: minimumAspectRatio,
                                                         maximumAspectRatio: maximumAspectRatio,
                                                         quadratureTolerance: quadratureTolerance,
                                                         minimumSize: minimumSize,
                                                         minimumConfidence: minimumConfidence,
                                                         maximumObservations: maximumObservations), imageSource: imageSource)
    }

    @available(iOS 14.0, macOS 11.0, *)
    public func humanBodyPoseDetection(imageSource: VisionImageSource) throws -> [VNHumanBodyPoseObservation] {
        try multiObservationHandler(.humanBodyPoseDetection, imageSource: imageSource)
    }

    public func imageClassification(imageSource: VisionImageSource) throws -> [VNClassificationObservation] {
        try multiObservationHandler(.imageClassification, imageSource: imageSource)
    }

}

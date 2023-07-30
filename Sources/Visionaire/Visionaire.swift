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
                let _ = try await perform(tasks, on: solidImage)
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
                        orientation: CGImagePropertyOrientation? = nil) async throws -> [VisionTaskResult] {
        await MainActor.run {
            isProcessing = true
        }

        let taskResults: [VisionTaskResult]

        do {
            try imageSource.VNImageHandler(orientation: orientation, context: context).perform(requests)
            taskResults = requests.map(VisionTaskResult.init)
            await MainActor.run {
                isProcessing = false
            }
        } catch {
            await MainActor.run {
                isProcessing = false
            }
            throw error
        }

        return taskResults
    }

    //MARK: Single Request
    public func perform(_ request: VNRequest,
                        ciContext context: CIContext? = nil,
                        on imageSource: VisionImageSource,
                        orientation: CGImagePropertyOrientation? = nil) async throws -> VisionTaskResult {
        guard let result = try await perform([request], ciContext: context, on: imageSource, orientation: orientation).first else {
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
                        orientation: CGImagePropertyOrientation? = nil) async throws -> [VisionTaskResult] {
        try await perform(tasks.map(\.request), ciContext: context, on: imageSource, orientation: orientation)
    }

    //MARK: Single Task

    public func perform(_ task: VisionTask,
                        ciContext context: CIContext? = nil,
                        on imageSource: VisionImageSource,
                        orientation: CGImagePropertyOrientation? = nil) async throws -> VisionTaskResult {
        guard let result = try await perform([task], ciContext: context, on: imageSource, orientation: orientation).first else {
            throw VisionaireError.noResult
        }
        return result
    }

}

//MARK: - Observation Casting

extension Visionaire {

    private func multiObservationHandler<T>(_ task: VisionTask, imageSource: VisionImageSource) async throws -> [T] {
        let result = try await perform(task, on: imageSource)
        return result.observations.compactMap { $0 as? T }
    }

    private func singleObservationHandler<T>(_ task: VisionTask, imageSource: VisionImageSource) async throws -> T {
        let result = try await perform(task, on: imageSource)
        guard let observation = result.observations.first, let first = observation as? T else {
            throw VisionaireError.noObservations
        }
        return first
    }

}

//MARK: - Convenience Methods (Observation Based)

extension Visionaire {

    public func horizonDetection(imageSource: VisionImageSource) async throws -> VNHorizonObservation {
        try await singleObservationHandler(.horizonDetection, imageSource: imageSource)
    }

    public func saliencyAnalysis(mode: SaliencyMode, imageSource: VisionImageSource) async throws -> [VNSaliencyImageObservation] {
        try await multiObservationHandler(mode.task, imageSource: imageSource)
    }

    public func saliencyAnalysis(mode: SaliencyMode, imageSource: VisionImageSource) async throws -> [VNRectangleObservation] {
        let saliency: [VNSaliencyImageObservation] = try await multiObservationHandler(mode.task, imageSource: imageSource)
        return saliency.flatMap { $0.salientObjects ?? [] }
    }

    public func faceDetection(imageSource: VisionImageSource, regionOfInterest: CGRect? = nil, revision: Int? = nil) async throws -> [VNFaceObservation] {
        try await multiObservationHandler(.faceDetection, imageSource: imageSource)
    }

    public func faceLandmarkDetection(imageSource: VisionImageSource, regionOfInterest: CGRect? = nil, revision: Int? = nil) async throws -> [VNFaceObservation] {
        try await multiObservationHandler(.faceLandmarkDetection, imageSource: imageSource)
    }

    public func faceCaptureQualityDetection(imageSource: VisionImageSource, regionOfInterest: CGRect? = nil, revision: Int? = nil) async throws -> [VNFaceObservation] {
        try await multiObservationHandler(.faceCaptureQuality, imageSource: imageSource)
    }

    @available(iOS 15.0, macOS 12.0, *)
    public func personSegmentation(imageSource: VisionImageSource) async throws -> [VNPixelBufferObservation] {
        try await multiObservationHandler(.personSegmentation, imageSource: imageSource)
    }

    @available(iOS 15.0, macOS 12.0, *)
    public func personSegmentation(imageSource: VisionImageSource, qualityLevel: VNGeneratePersonSegmentationRequest.QualityLevel) async throws -> [VNPixelBufferObservation] {
        try await multiObservationHandler(.personSegmentation(qualityLevel: qualityLevel), imageSource: imageSource)
    }

    @available(iOS 15.0, macOS 12.0, *)
    public func documentSegmentation(imageSource: VisionImageSource) async throws -> [VNRectangleObservation] {
        try await multiObservationHandler(.documentSegmentation, imageSource: imageSource)
    }

    @available(iOS 15.0, macOS 12.0, *)
    public func humanRectanglesDetection(imageSource: VisionImageSource) async throws -> [VNHumanObservation] {
        try await multiObservationHandler(.humanRectanglesDetection, imageSource: imageSource)
    }

    public func rectanglesDetection(imageSource: VisionImageSource,
                                    minimumAspectRatio: VNAspectRatio? = nil,
                                    maximumAspectRatio: VNAspectRatio? = nil,
                                    quadratureTolerance: VNDegrees? = nil,
                                    minimumSize: Float? = nil,
                                    minimumConfidence: VNConfidence? = nil,
                                    maximumObservations: Int? = nil) async throws -> [VNRectangleObservation] {
        try await multiObservationHandler(.rectanglesDetection(minimumAspectRatio: minimumAspectRatio,
                                                               maximumAspectRatio: maximumAspectRatio,
                                                               quadratureTolerance: quadratureTolerance,
                                                               minimumSize: minimumSize,
                                                               minimumConfidence: minimumConfidence,
                                                               maximumObservations: maximumObservations), imageSource: imageSource)
    }

    @available(iOS 14.0, macOS 11.0, *)
    public func humanBodyPoseDetection(imageSource: VisionImageSource) async throws -> [VNHumanBodyPoseObservation] {
        try await multiObservationHandler(.humanBodyPoseDetection, imageSource: imageSource)
    }

}

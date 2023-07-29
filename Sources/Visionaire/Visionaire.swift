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
                let _ = try await performTasks(tasks, on: solidImage)
                debugPrint("[Visionaire] Warmed up...")
            } catch {
                debugPrint(error)
            }
        }
    }
}

protocol VisionInputSource {}

extension CGImage: VisionInputSource {}
extension CIImage: VisionInputSource {}
extension CVPixelBuffer: VisionInputSource {}

@available(macOS 11.0, iOS 14.0, *)
extension CMSampleBuffer: VisionInputSource {}

extension Data: VisionInputSource {}
extension URL: VisionInputSource {}

//MARK: - Image Handlers
extension Visionaire {

    private func optionsForContext(_ context: CIContext?) -> [VNImageOption : Any] {
        [.ciContext: context ?? kVisionaireContext]
    }

    private func imageHandler(for image: CGImage, orientation: CGImagePropertyOrientation? = nil, context: CIContext? = nil) -> VNImageRequestHandler {
        if let orientation {
            return VNImageRequestHandler(cgImage: image, orientation: orientation, options: optionsForContext(context))
        } else {
            return VNImageRequestHandler(cgImage: image, options: optionsForContext(context))
        }
    }

    private func imageHandler(for image: CIImage, orientation: CGImagePropertyOrientation? = nil, context: CIContext? = nil) -> VNImageRequestHandler {
        if let orientation {
            return VNImageRequestHandler(ciImage: image, orientation: orientation, options: optionsForContext(context))
        } else {
            return VNImageRequestHandler(ciImage: image, options: optionsForContext(context))
        }
    }

    private func imageHandler(for image: CVPixelBuffer, orientation: CGImagePropertyOrientation? = nil, context: CIContext? = nil) -> VNImageRequestHandler {
        if let orientation {
            return VNImageRequestHandler(cvPixelBuffer: image, orientation: orientation, options: optionsForContext(context))
        } else {
            return VNImageRequestHandler(cvPixelBuffer: image, options: optionsForContext(context))
        }
    }

    @available(macOS 11.0, iOS 14.0, *)
    private func imageHandler(for image: CMSampleBuffer, orientation: CGImagePropertyOrientation? = nil, context: CIContext? = nil) -> VNImageRequestHandler {
        if let orientation {
            return VNImageRequestHandler(cmSampleBuffer: image, orientation: orientation, options: optionsForContext(context))
        } else {
            return VNImageRequestHandler(cmSampleBuffer: image, options: optionsForContext(context))
        }
    }

    private func imageHandler(for image: Data, orientation: CGImagePropertyOrientation? = nil, context: CIContext? = nil) -> VNImageRequestHandler {
        if let orientation {
            return VNImageRequestHandler(data: image, orientation: orientation, options: optionsForContext(context))
        } else {
            return VNImageRequestHandler(data: image, options: optionsForContext(context))
        }
    }

    private func imageHandler(for image: URL, orientation: CGImagePropertyOrientation? = nil, context: CIContext? = nil) -> VNImageRequestHandler {
        if let orientation {
            return VNImageRequestHandler(url: image, orientation: orientation, options: optionsForContext(context))
        } else {
            return VNImageRequestHandler(url: image, options: optionsForContext(context))
        }
    }

}

//MARK: - Task Execution
extension Visionaire {

    private func setupRequestsForTasks(_ tasks: [VisionTask],
                                       regionOfInterest: CGRect? = nil,
                                       preferBackgroundProcessing: Bool? = nil,
                                       usesCPUOnly: Bool? = nil) -> [VNImageBasedRequest] {
        tasks.map { task in
            let request = task.request

            if let regionOfInterest {
                request.regionOfInterest = regionOfInterest
            }

            if let preferBackgroundProcessing {
                request.preferBackgroundProcessing = preferBackgroundProcessing
            }

            if let usesCPUOnly {
                request.usesCPUOnly = usesCPUOnly
            }

            return request
        }
    }

    //MARK: Multiple tasks

    public func performTasks(_ tasks: [VisionTask],
                             ciContext context: CIContext? = nil,
                             on imageSource: CIImage,
                             regionOfInterest: CGRect? = nil,
                             preferBackgroundProcessing: Bool? = nil,
                             usesCPUOnly: Bool? = nil
    ) async throws -> [VisionTaskResult] {

        await MainActor.run {
            isProcessing = true
        }

        let requests = setupRequestsForTasks(tasks, regionOfInterest: regionOfInterest, preferBackgroundProcessing: preferBackgroundProcessing, usesCPUOnly: usesCPUOnly)
        let taskResults: [VisionTaskResult]

        do {
            try imageHandler(for: imageSource, context: context).perform(requests)
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

    //MARK: Single Task

    public func performTask(_ task: VisionTask,
                            ciContext context: CIContext? = nil,
                            on imageSource: CIImage,
                            regionOfInterest: CGRect? = nil,
                            preferBackgroundProcessing: Bool? = nil,
                            usesCPUOnly: Bool? = nil
    ) async throws -> VisionTaskResult {
        guard let result = try await performTasks([task],
                                                  ciContext: context,
                                                  on: imageSource,
                                                  regionOfInterest: regionOfInterest,
                                                  preferBackgroundProcessing: preferBackgroundProcessing,
                                                  usesCPUOnly: usesCPUOnly
        ).first else {
            throw VisionaireError.noResult
        }
        return result
    }

}

//MARK: - Observation Casting

extension Visionaire {

    private func multiObservationHandler<T>(_ task: VisionTask, image: CIImage) async throws -> [T] {
        let result = try await performTask(task, on: image)
        return result.observations.compactMap { $0 as? T }
    }

    private func singleObservationHandler<T>(_ task: VisionTask, image: CIImage) async throws -> T {
        let result = try await performTask(task, on: image)
        guard let observation = result.observations.first, let first = observation as? T else {
            throw VisionaireError.noObservations
        }
        return first
    }

}

//MARK: - Convenience Methods (Observation Based)

extension Visionaire {

    public func horizonDetection(image: CIImage) async throws -> VNHorizonObservation {
        try await singleObservationHandler(.horizonDetection, image: image)
    }

    public func saliencyAnalysis(mode: SaliencyMode, image: CIImage) async throws -> [VNSaliencyImageObservation] {
        try await multiObservationHandler(mode.task, image: image)
    }

    public func saliencyAnalysis(mode: SaliencyMode, image: CIImage) async throws -> [VNRectangleObservation] {
        let saliency: [VNSaliencyImageObservation] = try await multiObservationHandler(mode.task, image: image)
        return saliency.flatMap { $0.salientObjects ?? [] }
    }

    public func faceDetection(image: CIImage, regionOfInterest: CGRect? = nil, revision: Int? = nil) async throws -> [VNFaceObservation] {
        try await multiObservationHandler(.faceDetection, image: image)
    }

    public func faceLandmarkDetection(image: CIImage, regionOfInterest: CGRect? = nil, revision: Int? = nil) async throws -> [VNFaceObservation] {
        try await multiObservationHandler(.faceLandmarkDetection, image: image)
    }

    public func faceCaptureQualityDetection(image: CIImage, regionOfInterest: CGRect? = nil, revision: Int? = nil) async throws -> [VNFaceObservation] {
        try await multiObservationHandler(.faceCaptureQuality, image: image)
    }

    @available(iOS 15.0, macOS 12.0, *)
    public func personSegmentation(image: CIImage) async throws -> [VNPixelBufferObservation] {
        try await multiObservationHandler(.personSegmentation, image: image)
    }

    @available(iOS 15.0, macOS 12.0, *)
    public func personSegmentation(image: CIImage, qualityLevel: VNGeneratePersonSegmentationRequest.QualityLevel) async throws -> [VNPixelBufferObservation] {
        try await multiObservationHandler(.personSegmentation(qualityLevel: qualityLevel), image: image)
    }

    @available(iOS 15.0, macOS 12.0, *)
    public func documentSegmentation(image: CIImage) async throws -> [VNRectangleObservation] {
        try await multiObservationHandler(.documentSegmentation, image: image)
    }

    @available(iOS 15.0, macOS 12.0, *)
    public func humanRectanglesDetection(image: CIImage) async throws -> [VNHumanObservation] {
        try await multiObservationHandler(.humanRectanglesDetection, image: image)
    }

    public func rectanglesDetection(image: CIImage,
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
                                                               maximumObservations: maximumObservations), image: image)
    }

    @available(iOS 14.0, macOS 11.0, *)
    public func humanBodyPoseDetection(image: CIImage) async throws -> [VNHumanBodyPoseObservation] {
        try await multiObservationHandler(.humanBodyPoseDetection, image: image)
    }

}

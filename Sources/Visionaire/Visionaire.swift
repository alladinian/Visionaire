import Vision
import CoreImage

private let kVisionaireContext: CIContext = CIContext(options: [.name: "VisionaireCIContext"])

public final class Visionaire {

    public static let shared = Visionaire()

    private init() {
        // Warm-up
        let solidImage = CIImage(color: .red)
        let smallRect  = CGRect(x: 0, y: 0, width: 64, height: 64)
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            let handler = self.imageHandler(for: solidImage.cropped(to: smallRect))
            do {
                try handler.perform([VisionTask.faceDetection.request(completion: { _, _ in })])
                debugPrint("[Visionaire] Warmed up...")//, kVisionaireContext)
            } catch {
                debugPrint(error)
            }
        }
    }
}

//MARK: - Image Handlers
extension Visionaire {

    private func imageHandler(for image: CIImage, context: CIContext? = nil) -> VNImageRequestHandler {
        VNImageRequestHandler(ciImage: image, options: [.ciContext: context ?? kVisionaireContext])
    }

}

//MARK: - Task Execution
extension Visionaire {

    //MARK: Multiple tasks

    public func performTasks(_ tasks: [VisionTask],
                             ciContext context: CIContext? = nil,
                             onImage image: CIImage,
                             regionOfInterest: CGRect? = nil,
                             revision: Int? = nil,
                             preferBackgroundProcessing: Bool = false
    ) async throws -> [VisionTaskResult] {

        var taskResults = [VisionTaskResult]()

        let requests = tasks.map {
            let request = $0.request(revision: revision) { request, error in
                taskResults.append(VisionTaskResult(request: request, error: error))
            }

            if let regionOfInterest {
                request.regionOfInterest = regionOfInterest
            }

            if preferBackgroundProcessing {
                request.preferBackgroundProcessing = true
            }

            return request
        }

        try imageHandler(for: image, context: context).perform(requests)

        return taskResults
    }

    //MARK: Single Task

    public func performTask(_ task: VisionTask,
                            ciContext context: CIContext? = nil,
                            onImage image: CIImage,
                            regionOfInterest: CGRect? = nil,
                            revision: Int? = nil,
                            preferBackgroundProcessing: Bool = false
    ) async throws -> VisionTaskResult {

        var result: VisionTaskResult?

        let request = task.request(revision: revision) { request, error in
            result = VisionTaskResult(request: request, error: error)
        }

        if let regionOfInterest {
            request.regionOfInterest = regionOfInterest
        }

        if preferBackgroundProcessing {
            request.preferBackgroundProcessing = true
        }

        try imageHandler(for: image, context: context).perform([request])

        guard let result else {
            throw VisionaireError.noResult
        }

        return result
    }

}

//MARK: - Observation Casting

extension Visionaire {

    private func multiObservationHandler<T>(_ task: VisionTask, image: CIImage) async throws -> [T] {
        let result = try await performTask(task, onImage: image)

        if let error = result.error {
            throw error
        }

        return result.observations.compactMap { $0 as? T }
    }

    private func singleObservationHandler<T>(_ task: VisionTask, image: CIImage) async throws -> T {
        let result = try await performTask(task, onImage: image)
        guard let observation = result.observations.first, let first = observation as? T else {
            throw VisionaireError.noObservations
        }
        return first
    }

}

//MARK: - Convenience Methods (Observation Based)

extension Visionaire {

    public func horizonAngle(image: CIImage) async throws -> VNHorizonObservation {
        try await singleObservationHandler(.horizonDetection, image: image)
    }

    public func saliencyAnalysis(mode: SaliencyMode, image: CIImage) async throws -> [VNSaliencyImageObservation] {
        try await multiObservationHandler(mode.task, image: image)
    }

    public func faceDetection(image: CIImage, regionOfInterest: CGRect? = nil, revision: Int? = nil) async throws -> [VNFaceObservation] {
        try await multiObservationHandler(.faceDetection, image: image)
    }

    public func faceLandmarkDetection(image: CIImage, regionOfInterest: CGRect? = nil, revision: Int? = nil) async throws -> [VNFaceObservation] {
        try await multiObservationHandler(.faceLandmarkDetection, image: image)
    }

}

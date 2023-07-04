import Vision
import CoreImage

public enum SaliencyMode {
    case attention
    case object
}

public enum VisionTask {
    case horizonDetection
    case saliency(mode: SaliencyMode)
    case faceDetection
    case faceLandmarkDetection

    var requestType: VNImageBasedRequest.Type {
        switch self {
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
        }
    }

    var observationType: VNObservation.Type {
        switch self {
        case .horizonDetection:
            return VNHorizonObservation.self
        case .saliency:
            return VNSaliencyImageObservation.self
        case .faceDetection, .faceLandmarkDetection:
            return VNFaceObservation.self
        }
    }

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

public enum VisionaireError: Error {
    case noObservations
    case invalidImage
    case unknown
}

private let kVisionaireContext: CIContext = CIContext(options: [.name: "VisionaireCIContext"])

public class Visionaire {
    var runningRequests: [VNRequest] = []

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
                print("Warmed up", kVisionaireContext)
            } catch {
                print(error)
            }
        }
    }

    private func imageHandler(for image: CIImage, context: CIContext? = nil) -> VNImageRequestHandler {
        VNImageRequestHandler(ciImage: image, options: [.ciContext: context ?? kVisionaireContext])
    }

    public func performTasks(_ tasks: [VisionTask],
                             ciContext context: CIContext? = nil,
                             onImage image: CIImage,
                             regionOfInterest: CGRect? = nil,
                             revision: Int? = nil,
                             preferBackgroundProcessing: Bool = false
    ) async throws -> [(request: VNRequest, observation: VNObservation)] {

        var observations = [(VNRequest, VNObservation)]()

        let requests = tasks.map {
            let request = $0.request(revision: revision) { request, error in
                if let results = request.results {
                    for result in results {
                        observations.append((request, result))
                    }
                }
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

        return observations
    }

    public func horizonAngle(image: CIImage) async throws -> (VNRequest, VNHorizonObservation) {
        guard let observations = try await performTasks([.horizonDetection], onImage: image) as? [(VNRequest, VNHorizonObservation)] else {
            throw VisionaireError.noObservations
        }

        guard let top = observations.first else {
            throw VisionaireError.noObservations
        }

        return top
    }

    public func saliencyAnalysis(mode: SaliencyMode, image: CIImage) async throws -> [(VNRequest, VNSaliencyImageObservation)] {
        guard let observations = try await performTasks([.saliency(mode: mode)], onImage: image) as? [(VNRequest, VNSaliencyImageObservation)] else {
            throw VisionaireError.noObservations
        }
        return observations
    }

    public func faceDetection(image: CIImage, regionOfInterest: CGRect? = nil, revision: Int? = nil) async throws -> [(VNRequest, VNFaceObservation)] {
        guard let observations = try await performTasks([.faceDetection], onImage: image, regionOfInterest: regionOfInterest, revision: revision) as? [(VNRequest, VNFaceObservation)] else {
            throw VisionaireError.noObservations
        }
        return observations
    }

    public func faceLandmarkDetection(image: CIImage, regionOfInterest: CGRect? = nil, revision: Int? = nil) async throws -> [(VNRequest, VNFaceObservation)] {
        guard let observations = try await performTasks([.faceLandmarkDetection], onImage: image, regionOfInterest: regionOfInterest, revision: revision) as? [(VNRequest, VNFaceObservation)] else {
            throw VisionaireError.noObservations
        }
        return observations
    }

}

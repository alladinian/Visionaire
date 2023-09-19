import Vision
import CoreImage

let kVisionaireContext: CIContext = CIContext(options: [.name: "VisionaireCIContext"])

public final class Visionaire: ObservableObject {

    public static let shared = Visionaire()

    public init() {}

    @MainActor
    @Published public private(set) var isProcessing: Bool = false

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
    @discardableResult
    public func perform(_ requests: [VNRequest],
                        ciContext context: CIContext? = nil,
                        on imageSource: VisionImageSource,
                        orientation: CGImagePropertyOrientation? = nil) throws -> [VNRequest] {
        DispatchQueue.main.async { [weak self] in
            self?.isProcessing = true
        }
        try imageSource.VNImageHandler(orientation: orientation, context: context).perform(requests)
        DispatchQueue.main.async { [weak self] in
            self?.isProcessing = false
        }
        return requests
    }

    //MARK: Single Request
    @discardableResult
    public func perform(_ request: VNRequest,
                        ciContext context: CIContext? = nil,
                        on imageSource: VisionImageSource,
                        orientation: CGImagePropertyOrientation? = nil) throws -> VNRequest {
        guard let result = try perform([request], ciContext: context, on: imageSource, orientation: orientation).first else {
            throw VisionaireError.noResult
        }
        return result
    }
}

//MARK: - Task Execution
extension Visionaire {
    //MARK: Multiple tasks
    @discardableResult
    public func perform(_ tasks: [VisionTask],
                        ciContext context: CIContext? = nil,
                        on imageSource: VisionImageSource,
                        orientation: CGImagePropertyOrientation? = nil) throws -> [VisionTaskResult] {
        try perform(tasks.map(\.request), ciContext: context, on: imageSource, orientation: orientation)
        return tasks.map(VisionTaskResult.init)
    }

    //MARK: Single Task
    @discardableResult
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

    //MARK: - Feature Print Generation

    public func featurePrintGeneration(imageSource: VisionImageSource) throws -> [VNFeaturePrintObservation] {
        try multiObservationHandler(.featurePrintGeneration, imageSource: imageSource)
    }

    public func featurePrintGeneration(imageSource: VisionImageSource, imageCropAndScaleOption: VNImageCropAndScaleOption) throws -> [VNFeaturePrintObservation] {
        try multiObservationHandler(.featurePrintGeneration(imageCropAndScaleOption: imageCropAndScaleOption), imageSource: imageSource)
    }

    //MARK: - Person Segmentation

    @available(iOS 15.0, macCatalyst 15.0, macOS 12.0, tvOS 15.0, *)
    public func personSegmentation(imageSource: VisionImageSource) throws -> [VNPixelBufferObservation] {
        try multiObservationHandler(.personSegmentation, imageSource: imageSource)
    }

    @available(iOS 15.0, macCatalyst 15.0, macOS 12.0, tvOS 15.0, *)
    public func personSegmentation(imageSource: VisionImageSource,
                                   qualityLevel: VNGeneratePersonSegmentationRequest.QualityLevel? = nil,
                                   outputPixelFormat: OSType? = nil) throws -> [VNPixelBufferObservation] {
        try multiObservationHandler(.personSegmentation(qualityLevel: qualityLevel, outputPixelFormat: outputPixelFormat), imageSource: imageSource)
    }

    //MARK: - Document Segmentation

    @available(iOS 15.0, macCatalyst 15.0, macOS 12.0, tvOS 15.0, *)
    public func documentSegmentation(imageSource: VisionImageSource) throws -> [VNRectangleObservation] {
        try multiObservationHandler(.documentSegmentation, imageSource: imageSource)
    }

    //MARK: - Saliency

    public func attentionSaliencyAnalysis(imageSource: VisionImageSource) throws -> [VNSaliencyImageObservation] {
        try multiObservationHandler(.attentionSaliency, imageSource: imageSource)
    }

    public func attentionSaliencyAnalysis(imageSource: VisionImageSource) throws -> [VNRectangleObservation] {
        let saliency: [VNSaliencyImageObservation] = try multiObservationHandler(.attentionSaliency, imageSource: imageSource)
        return saliency.flatMap { $0.salientObjects ?? [] }
    }

    public func objectnessSaliencyAnalysis(imageSource: VisionImageSource) throws -> [VNSaliencyImageObservation] {
        try multiObservationHandler(.objectnessSaliency, imageSource: imageSource)
    }

    public func objectnessSaliencyAnalysis(imageSource: VisionImageSource) throws -> [VNRectangleObservation] {
        let saliency: [VNSaliencyImageObservation] = try multiObservationHandler(.objectnessSaliency, imageSource: imageSource)
        return saliency.flatMap { $0.salientObjects ?? [] }
    }

    //MARK: - Rectangle Tracking

    public func rectangleTracking(imageSource: VisionImageSource,
                                  observation: VNRectangleObservation,
                                  trackingLevel: VNRequestTrackingLevel? = nil,
                                  isLastFrame: Bool? = nil) throws -> VNDetectedObjectObservation {
        try singleObservationHandler(.rectangleTracking(observation: observation,
                                                        trackingLevel: trackingLevel,
                                                        isLastFrame: isLastFrame), imageSource: imageSource)
    }

    //MARK: - Object Tracking

    public func objectTracking(imageSource: VisionImageSource,
                                  observation: VNDetectedObjectObservation,
                                  trackingLevel: VNRequestTrackingLevel? = nil,
                                  isLastFrame: Bool? = nil) throws -> VNDetectedObjectObservation {
        try singleObservationHandler(.objectTracking(observation: observation,
                                                     trackingLevel: trackingLevel,
                                                     isLastFrame: isLastFrame), imageSource: imageSource)
    }

    //MARK: - Rectangles Detection

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


    //MARK: - Face Capture Quality

    public func faceCaptureQualityDetection(imageSource: VisionImageSource, regionOfInterest: CGRect? = nil, revision: Int? = nil) throws -> [VNFaceObservation] {
        try multiObservationHandler(.faceCaptureQuality, imageSource: imageSource)
    }

    //MARK: - Face Landmark Detection

    public func faceLandmarkDetection(imageSource: VisionImageSource, regionOfInterest: CGRect? = nil, revision: Int? = nil) throws -> [VNFaceObservation] {
        try multiObservationHandler(.faceLandmarkDetection, imageSource: imageSource)
    }

    //MARK: - Face Detection

    public func faceDetection(imageSource: VisionImageSource, regionOfInterest: CGRect? = nil, revision: Int? = nil) throws -> [VNFaceObservation] {
        try multiObservationHandler(.faceDetection, imageSource: imageSource)
    }

    //MARK: - Human Rectangles Detection

    @available(iOS 15.0, macCatalyst 15.0, macOS 12.0, tvOS 15.0, *)
    public func humanRectanglesDetection(imageSource: VisionImageSource) throws -> [VNHumanObservation] {
        try multiObservationHandler(.humanRectanglesDetection, imageSource: imageSource)
    }

    @available(iOS 15.0, macCatalyst 15.0, macOS 12.0, tvOS 15.0, *)
    public func humanRectanglesDetection(imageSource: VisionImageSource, upperBodyOnly: Bool) throws -> [VNHumanObservation] {
        try multiObservationHandler(.humanRectanglesDetection(upperBodyOnly: upperBodyOnly), imageSource: imageSource)
    }

    //MARK: - Human Body Detection

    @available(iOS 14.0, macCatalyst 14.0, macOS 11.0, tvOS 14.0, *)
    public func humanBodyPoseDetection(imageSource: VisionImageSource) throws -> [VNHumanBodyPoseObservation] {
        try multiObservationHandler(.humanBodyPoseDetection, imageSource: imageSource)
    }

    //MARK: - Human Hand Pose Detection

    @available(iOS 14.0, macCatalyst 14.0, macOS 11.0, tvOS 14.0, *)
    public func humanHandPoseDetection(imageSource: VisionImageSource, maximumHandCount: Int) throws -> [VNHumanHandPoseObservation] {
        try multiObservationHandler(.humanHandPoseDetection(maximumHandCount: maximumHandCount), imageSource: imageSource)
    }

    //MARK: - Animal Detection

    public func animalDetection(imageSource: VisionImageSource) throws -> [VNRecognizedObjectObservation] {
        try multiObservationHandler(.animalDetection, imageSource: imageSource)
    }

    //MARK: - Trajectories

    @available(iOS 14.0, macCatalyst 14.0, macOS 11.0, tvOS 14.0, *)
    public func trajectoriesDetection(imageSource: VisionImageSource,
                                      frameAnalysisSpacing: CMTime,
                                      trajectoryLength: Int,
                                      objectMinimumNormalizedRadius: Float? = nil,
                                      objectMaximumNormalizedRadius: Float? = nil) throws -> [VNTrajectoryObservation] {
        try multiObservationHandler(.trajectoriesDetection(frameAnalysisSpacing: frameAnalysisSpacing,
                                                           trajectoryLength: trajectoryLength,
                                                           objectMinimumNormalizedRadius: objectMinimumNormalizedRadius,
                                                           objectMaximumNormalizedRadius: objectMaximumNormalizedRadius), imageSource: imageSource)
    }

    @available(iOS 15.0, macCatalyst 15.0, macOS 12.0, tvOS 15.0, *)
    public func trajectoriesDetection(imageSource: VisionImageSource,
                                      frameAnalysisSpacing: CMTime,
                                      trajectoryLength: Int,
                                      targetFrameTime: CMTime? = nil,
                                      objectMinimumNormalizedRadius: Float? = nil,
                                      objectMaximumNormalizedRadius: Float? = nil) throws -> [VNTrajectoryObservation] {
        try multiObservationHandler(.trajectoriesDetection(frameAnalysisSpacing: frameAnalysisSpacing,
                                                           trajectoryLength: trajectoryLength,
                                                           targetFrameTime: targetFrameTime,
                                                           objectMinimumNormalizedRadius: objectMinimumNormalizedRadius,
                                                           objectMaximumNormalizedRadius: objectMaximumNormalizedRadius), imageSource: imageSource)
    }

    //MARK: - Contours

    @available(iOS 14.0, macCatalyst 14.0, macOS 11.0, tvOS 14.0, *)
    public func contoursDetection(imageSource: VisionImageSource) throws -> [VNContoursObservation] {
        try multiObservationHandler(.contoursDetection, imageSource: imageSource)
    }


    @available(iOS 14.0, macCatalyst 14.0, macOS 11.0, tvOS 14.0, *)
    public func contoursDetection(imageSource: VisionImageSource,
                                  contrastAdjustment: Float? = nil,
                                  detectsDarkOnLight: Bool? = nil,
                                  maximumImageDimension: Int? = nil) throws -> [VNContoursObservation] {
        try multiObservationHandler(.contoursDetection(contrastAdjustment: contrastAdjustment,
                                                       detectsDarkOnLight: detectsDarkOnLight,
                                                       maximumImageDimension: maximumImageDimension), imageSource: imageSource)
    }

    @available(iOS 15.0, macCatalyst 15.0, macOS 12.0, tvOS 15.0, *)
    public func contoursDetection(imageSource: VisionImageSource,
                                  contrastAdjustment: Float? = nil,
                                  contrastPivot: NSNumber? = nil,
                                  detectsDarkOnLight: Bool? = nil,
                                  maximumImageDimension: Int? = nil) throws -> [VNContoursObservation] {
        try multiObservationHandler(.contoursDetection(contrastAdjustment: contrastAdjustment,
                                                       contrastPivot: contrastPivot,
                                                       detectsDarkOnLight: detectsDarkOnLight,
                                                       maximumImageDimension: maximumImageDimension), imageSource: imageSource)
    }

    //MARK: - Optical Flow

    @available(iOS 14.0, macCatalyst 14.0, macOS 11.0, tvOS 14.0, *)
    public func opticalFlow(imageSource: VisionImageSource,
                            targetedImage: VisionImageSource,
                            computationAccuracy: VNGenerateOpticalFlowRequest.ComputationAccuracy? = nil,
                            outputPixelFormat: OSType? = nil) throws -> [VNPixelBufferObservation] {
        try multiObservationHandler(.opticalFlow(targetedImage: targetedImage,
                                                 computationAccuracy: computationAccuracy,
                                                 outputPixelFormat: outputPixelFormat), imageSource: imageSource)
    }

    @available(iOS 16.0, macCatalyst 16.0, macOS 13.0, tvOS 16.0, *)
    public func opticalFlow(imageSource: VisionImageSource,
                            targetedImage: VisionImageSource,
                            computationAccuracy: VNGenerateOpticalFlowRequest.ComputationAccuracy? = nil,
                            outputPixelFormat: OSType? = nil,
                            keepNetworkOutput: Bool? = nil) throws -> [VNPixelBufferObservation] {
        try multiObservationHandler(.opticalFlow(targetedImage: targetedImage,
                                                 computationAccuracy: computationAccuracy,
                                                 outputPixelFormat: outputPixelFormat,
                                                 keepNetworkOutput: keepNetworkOutput), imageSource: imageSource)
    }

    //MARK: - Barcode Detection

    public func barcodeDetection(imageSource: VisionImageSource) throws -> [VNBarcodeObservation] {
        try multiObservationHandler(.barcodeDetection, imageSource: imageSource)
    }

    @available(iOS 17.0, macCatalyst 17.0, macOS 14.0, tvOS 17.0, *)
    public func barcodeDetection(imageSource: VisionImageSource, coalesceCompositeSymbologies: Bool) throws -> [VNBarcodeObservation] {
        try multiObservationHandler(.barcodeDetection(coalesceCompositeSymbologies: coalesceCompositeSymbologies), imageSource: imageSource)
    }

    //MARK: - Text Rectangles Detection

    public func textRectanglesDetection(imageSource: VisionImageSource) throws -> [VNTextObservation] {
        try multiObservationHandler(.textRectanglesDetection, imageSource: imageSource)
    }

    public func textRectanglesDetection(imageSource: VisionImageSource, reportCharacterBoxes: Bool) throws -> [VNTextObservation] {
        try multiObservationHandler(.textRectanglesDetection(reportCharacterBoxes: reportCharacterBoxes), imageSource: imageSource)
    }

    //MARK: - Text Recognition

    public func textRecognition(imageSource: VisionImageSource) throws -> [VNRecognizedTextObservation] {
        try multiObservationHandler(.textRecognition, imageSource: imageSource)
    }

    public func textRecognition(imageSource: VisionImageSource,
                                minimumTextHeight: Float? = nil,
                                recognitionLevel: VNRequestTextRecognitionLevel? = nil,
                                recognitionLanguages: [String]? = nil,
                                usesLanguageCorrection: Bool? = nil,
                                customWords: [String]? = nil) throws -> [VNRecognizedTextObservation] {
        try multiObservationHandler(.textRecognition(minimumTextHeight: minimumTextHeight,
                                                     recognitionLevel: recognitionLevel,
                                                     recognitionLanguages: recognitionLanguages,
                                                     usesLanguageCorrection: usesLanguageCorrection,
                                                     customWords: customWords), imageSource: imageSource)
    }

    @available(iOS 16.0, macCatalyst 16.0, macOS 13.0, tvOS 16.0, *)
    public func textRecognition(imageSource: VisionImageSource,
                                minimumTextHeight: Float? = nil,
                                recognitionLevel: VNRequestTextRecognitionLevel? = nil,
                                automaticallyDetectsLanguage: Bool? = nil,
                                recognitionLanguages: [String]? = nil,
                                usesLanguageCorrection: Bool? = nil,
                                customWords: [String]? = nil) throws -> [VNRecognizedTextObservation] {
        try multiObservationHandler(.textRecognition(minimumTextHeight: minimumTextHeight,
                                                     recognitionLevel: recognitionLevel,
                                                     automaticallyDetectsLanguage: automaticallyDetectsLanguage,
                                                     recognitionLanguages: recognitionLanguages,
                                                     usesLanguageCorrection: usesLanguageCorrection,
                                                     customWords: customWords), imageSource: imageSource)
    }

    //MARK: - Horizon Detection

    public func horizonDetection(imageSource: VisionImageSource) throws -> VNHorizonObservation {
        try singleObservationHandler(.horizonDetection, imageSource: imageSource)
    }

    //MARK: - Image Classification

    public func imageClassification(imageSource: VisionImageSource) throws -> [VNClassificationObservation] {
        try multiObservationHandler(.imageClassification, imageSource: imageSource)
    }

    //MARK: - Translational Registration

    public  func translationalImageRegistration(imageSource: VisionImageSource,
                                                targetedImage: VisionImageSource,
                                                orientation: CGImagePropertyOrientation? = nil,
                                                context: CIContext? = nil) throws -> [VNImageTranslationAlignmentObservation] {
        try multiObservationHandler(.translationalImageRegistration(targetedImage: targetedImage,
                                                                    orientation: orientation,
                                                                    context: context), imageSource: imageSource)
    }

    //MARK: - Homographic Registration

    public  func homographicImageRegistration(imageSource: VisionImageSource,
                                                targetedImage: VisionImageSource,
                                                orientation: CGImagePropertyOrientation? = nil,
                                                context: CIContext? = nil) throws -> [VNImageHomographicAlignmentObservation] {
        try multiObservationHandler(.homographicImageRegistration(targetedImage: targetedImage,
                                                                  orientation: orientation,
                                                                  context: context), imageSource: imageSource)
    }

    //MARK: - Custom CoreML Models

    public func customClassification(imageSource: VisionImageSource,
                                     model: VNCoreMLModel,
                                     inputImageFeatureName: String? = nil,
                                     featureProvider: MLFeatureProvider? = nil,
                                     imageCropAndScaleOption: VNImageCropAndScaleOption? = nil) throws -> [VNClassificationObservation] {
        try multiObservationHandler(.customClassification(model: model,
                                                          inputImageFeatureName: inputImageFeatureName,
                                                          featureProvider: featureProvider,
                                                          imageCropAndScaleOption: imageCropAndScaleOption),
                                    imageSource: imageSource)
    }

    public func customImageToImage(imageSource: VisionImageSource,
                                   model: VNCoreMLModel,
                                   inputImageFeatureName: String? = nil,
                                   featureProvider: MLFeatureProvider? = nil,
                                   imageCropAndScaleOption: VNImageCropAndScaleOption? = nil) throws -> [VNPixelBufferObservation] {
        try multiObservationHandler(.customImageToImage(model: model,
                                                        inputImageFeatureName: inputImageFeatureName,
                                                        featureProvider: featureProvider,
                                                        imageCropAndScaleOption: imageCropAndScaleOption),
                                    imageSource: imageSource)
    }

    public func customRecognition(imageSource: VisionImageSource,
                                  model: VNCoreMLModel,
                                  inputImageFeatureName: String? = nil,
                                  featureProvider: MLFeatureProvider? = nil,
                                  imageCropAndScaleOption: VNImageCropAndScaleOption? = nil) throws -> [VNRecognizedObjectObservation] {
        try multiObservationHandler(.customRecognition(model: model,
                                                       inputImageFeatureName: inputImageFeatureName,
                                                       featureProvider: featureProvider,
                                                       imageCropAndScaleOption: imageCropAndScaleOption),
                                    imageSource: imageSource)
    }

    public func customGeneric(imageSource: VisionImageSource,
                              model: VNCoreMLModel,
                              inputImageFeatureName: String? = nil,
                              featureProvider: MLFeatureProvider? = nil,
                              imageCropAndScaleOption: VNImageCropAndScaleOption? = nil) throws -> [VNCoreMLFeatureValueObservation] {
        try multiObservationHandler(.customGeneric(model: model,
                                                   inputImageFeatureName: inputImageFeatureName,
                                                   featureProvider: featureProvider,
                                                   imageCropAndScaleOption: imageCropAndScaleOption),
                                    imageSource: imageSource)
    }

    //MARK: - Human Body Pose Detection (3D)

    @available(iOS 17.0, macCatalyst 17.0, macOS 14.0, tvOS 17.0, *)
    public func humanBodyPoseDetection3D(imageSource: VisionImageSource) throws -> [VNHumanBodyPose3DObservation] {
        try multiObservationHandler(.humanBodyPoseDetection3D, imageSource: imageSource)
    }

    //MARK: - Animal Body Pose Detection

    @available(iOS 17.0, macCatalyst 17.0, macOS 14.0, tvOS 17.0, *)
    public func animalBodyPoseDetection(imageSource: VisionImageSource) throws -> [VNAnimalBodyPoseObservation] {
        try multiObservationHandler(.animalBodyPoseDetection, imageSource: imageSource)
    }

    //MARK: - Track Optical Flow

    @available(iOS 17.0, macCatalyst 17.0, macOS 14.0, tvOS 17.0, *)
    public func opticalFlowTracking(imageSource: VisionImageSource,
                                    frameAnalysisSpacing: CMTime,
                                    computationAccuracy: VNTrackOpticalFlowRequest.ComputationAccuracy? = nil,
                                    outputPixelFormat: OSType? = nil,
                                    keepNetworkOutput: Bool? = nil) throws -> [VNPixelBufferObservation] {
        try multiObservationHandler(.opticalFlowTracking(frameAnalysisSpacing: frameAnalysisSpacing,
                                                         computationAccuracy: computationAccuracy,
                                                         outputPixelFormat: outputPixelFormat,
                                                         keepNetworkOutput: keepNetworkOutput), imageSource: imageSource)
    }

    //MARK: - Track Translational Image Registration

    @available(iOS 17.0, macCatalyst 17.0, macOS 14.0, tvOS 17.0, *)
    public func translationalImageRegistrationTracking(imageSource: VisionImageSource, frameAnalysisSpacing: CMTime) throws -> [VNImageTranslationAlignmentObservation] {
        try multiObservationHandler(.translationalImageRegistrationTracking(frameAnalysisSpacing: frameAnalysisSpacing), imageSource: imageSource)
    }

    //MARK: - Track Homographic Registration

    @available(iOS 17.0, macCatalyst 17.0, macOS 14.0, tvOS 17.0, *)
    public func homographicImageRegistrationTracking(imageSource: VisionImageSource, frameAnalysisSpacing: CMTime) throws -> [VNImageHomographicAlignmentObservation] {
        try multiObservationHandler(.homographicImageRegistrationTracking(frameAnalysisSpacing: frameAnalysisSpacing), imageSource: imageSource)
    }

    //MARK: - Foreground Instance Mask

    @available(iOS 17.0, macCatalyst 17.0, macOS 14.0, tvOS 17.0, *)
    public func foregroundInstanceMaskGeneration(imageSource: VisionImageSource) throws -> [VNInstanceMaskObservation] {
        try multiObservationHandler(.foregroundInstanceMaskGeneration, imageSource: imageSource)
    }

}

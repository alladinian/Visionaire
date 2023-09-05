# Visionaire

Streamlined, ergonomic APIs around Apple's Vision framework


## Supported Vision Tasks

| **Task**                                   | **Vision API**                                | **Visionaire Task**             | **iOS** | **macOS** |
| ------------------------------------------ | --------------------------------------------- | ------------------------------- | -------:| ---------:|
| **Generate Feature Print**                 | VNGenerateImageFeaturePrintRequest            | .featurePrintGeneration         |    13.0 |     10.15 |
| **Person Segmentation**                    | VNGeneratePersonSegmentationRequest           | .personSegmentation             |    15.0 |      12.0 |
| **Document Segmentation**                  | VNDetectDocumentSegmentationRequest           | .documentSegmentation           |    15.0 |      12.0 |
| **Attention Based Saliency**               | VNGenerateAttentionBasedSaliencyImageRequest  | .attentionSaliency              |    13.0 |     10.15 |
| **Objectness Based Saliency**              | VNGenerateObjectnessBasedSaliencyImageRequest | .objectnessSaliency             |    13.0 |     10.15 |
| **Track Rectangle**                        | VNTrackRectangleRequest                       | .rectangleTracking              |    11.0 |     10.13 |
| **Track Object**                           | VNTrackObjectRequest                          | .objectTracking                 |    11.0 |     10.13 |
| **Detect Rectangles**                      | VNDetectRectanglesRequest                     | .rectanglesDetection            |    11.0 |     10.13 |
| **Detect Face Capture Quality**            | VNDetectFaceCaptureQualityRequest             | .faceCaptureQuality             |    13.0 |     10.15 |
| **Detect Face Landmarks**                  | VNDetectFaceLandmarksRequest                  | .faceLandmarkDetection          |    11.0 |     10.13 |
| **Detect Face Rectangles**                 | VNDetectFaceRectanglesRequest                 | .faceDetection                  |    11.0 |     10.13 |
| **Detect Human Rectangles**                | VNDetectHumanRectanglesRequest                | .humanRectanglesDetection       |    13.0 |     10.15 |
| **Detect Human Body Pose**                 | VNDetectHumanBodyPoseRequest                  | .humanBodyPoseDetection         |    14.0 |      11.0 |
| **Detect Human Hand Pose**                 | VNDetectHumanHandPoseRequest                  | .humanHandPoseDetection         |    14.0 |      11.0 |
| **Recognize Animals**                      | VNRecognizeAnimalsRequest                     | .animalDetection                |    13.0 |     10.15 |
| **Detect Trajectories**                    | VNDetectTrajectoriesRequest                   | .trajectoriesDetection          |    14.0 |      11.0 |
| **Detect Contours**                        | VNDetectContoursRequest                       | .contoursDetection              |    14.0 |      11.0 |
| **Generate Optical Flow**                  | VNGenerateOpticalFlowRequest                  | .opticalFlowGeneration          |    14.0 |      11.0 |
| **Detect Barcodes**                        | VNDetectBarcodesRequest                       | .barcodeDetection               |    11.0 |     10.13 |
| **Detect Text Rectangles**                 | VNDetectTextRectanglesRequest                 | .textRectanglesDetection        |    11.0 |     10.13 |
| **Recognize Text**                         | VNRecognizeTextRequest                        | .textRecognition                |    13.0 |     10.15 |
| **Detect Horizon**                         | VNDetectHorizonRequest                        | .horizonDetection               |    11.0 |     10.13 |
| **Classify Image**                         | VNClassifyImageRequest                        | .imageClassification            |    13.0 |     10.15 |
| **Translational Image Registration**       | VNTranslationalImageRegistrationRequest       | .translationalImageRegistration |    11.0 |     10.13 |
| **Homographic Image Registration**         | VNHomographicImageRegistrationRequest         | .homographicImageRegistration   |    11.0 |     10.13 |
| **Detect Human Body Pose (3D)**            | VNDetectHumanBodyPose3DRequest                | n/a                             |    17.0 |      14.0 |
| **Detect Animal Body Pose**                | VNDetectAnimalBodyPoseRequest                 | n/a                             |    17.0 |      14.0 |
| **Track Optical Flow**                     | VNTrackOpticalFlowRequest                     | n/a                             |    17.0 |      14.0 |
| **Track Translational Image Registration** | VNTrackTranslationalImageRegistrationRequest  | n/a                             |    17.0 |      14.0 |
| **Track Homographic Image Registration**   | VNTrackHomographicImageRegistrationRequest    | n/a                             |    17.0 |      14.0 |
| **Generate Foreground Instance Mask**      | VNGenerateForegroundInstanceMaskRequest       | n/a                             |    17.0 |      14.0 |


## Supported Image Sources
- CGImage
- CIImage
- CVPixelBuffer
- CMSampleBuffer
- Data
- URL

## Examples

The main class for interfacing is called `Visionaire`. 

It's an `ObservableObject` and reports processing through a published property called `isProcessing`.

You can execute task on the `shared` Visionaire singleton or on your own instance (useful if you want to have separate processors reporting on their own).

There are two sets of apis, convenience methods & task-based methods.

Convenience methods have the benefit of returning typed results while tasks can be submitted en masse.

### Single task execution (convenience apis):

```swift
DispatchQueue.global(qos: .userInitiated).async {
    do {
        let image   = /* any supported image source, such as CGImage, CIImage, CVPixelBuffer, CMSampleBuffer, Data or URL */
        let horizon = try Visionaire.shared.horizonDetection(imageSource: image) // The result is a `VNHorizonObservation`
        let angle   = horizon.angle
        // Do something with the horizon angle
    } catch {
        print(error)
    }
}
```

### Single task execution (task-based apis):

```swift
DispatchQueue.global(qos: .userInitiated).async {
    do {
        let image       = /* any supported image source, such as CGImage, CIImage, CVPixelBuffer, CMSampleBuffer, Data or URL */
        let result      = try Visionaire.shared.perform(.horizonDetection, on: image) // The result is a `VisionTaskResult`
        let observation = result.observations.first as? VNHorizonObservation
        let angle       = observation?.angle
        // Do something with the horizon angle
    } catch {
        print(error)
    }
}
```

### Multiple task execution (task-based apis):

```swift
DispatchQueue.global(qos: .userInitiated).async {
    do {
        let image   = /* any supported image source, such as CGImage, CIImage, CVPixelBuffer, CMSampleBuffer, Data or URL */
        let results = try Visionaire.shared.perform([.horizonDetection, .personSegmentation(qualityLevel: .accurate)], on: image)
        for result in results {
            switch result.taskType {
            case .horizonDetection:
                let horizon = result.observations.first as? VNHorizonObservation
                // Do something with the observation
            case .personSegmentation:
                let segmentationObservations = result.observations as? [VNPixelBufferObservation]
                // Do something with the observations
            default:
                break
            }
        }   
    } catch {
        print(error)
    }
}
```

Of course, you can always perform `VNRequest`s as well if you like:

```swift
DispatchQueue.global(qos: .userInitiated).async {
    do {
        let image       = /* any supported image source, such as CGImage, CIImage, CVPixelBuffer, CMSampleBuffer, Data or URL */
        let results     = try visionaire.perform([VNDetectHorizonRequest()], on: image) // The results are `[VNRequest]`
        let observation = results.observations.first as? VNHorizonObservation
        let angle       = observation?.angle
        // Do something with the horizon angle
    } catch {
        print(error)
    }
}
```

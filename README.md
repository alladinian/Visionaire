# Visionaire 

>Streamlined, ergonomic APIs around Apple's Vision framework

![Swift](https://img.shields.io/badge/Swift-5.8+-ec775c?style=flat)
![iOS](https://img.shields.io/badge/iOS-13+-549bf5?style=flat)
![macOS](https://img.shields.io/badge/macOS-10.15+-549bf5?style=flat)
![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-Compatible-347d39?style=flat)


The main goal of `Visionaire` is to reduce ceremony and provide a consice set of APIs for Vision tasks.

Some of its features include:

- **Centralized list of all tasks**, available via the `VisionTaskType` enum (with platform availability checks).
- **Automatic image handling** for all supported image sources.
- **Convenience APIs for all tasks**, along with all available parameters for each task (with platform availability checks).
- Support for **custom CoreML models** (Classification, Image-To-Image, Object Recognition, Generic `VNCoreMLFeatureValueObservation`s).
- Support for **multiple task execution**, maintaining task type information in the results.
- Support for raw `VNRequest`s.
- All calls are **synchronous** (just like the original calls) - **no extra 'magic', assumptions or hidden juggling**.
- **SwiftUI extensions** for helping you **rapidly visualize results** (great for evaluation).

## Installation
`Visionaire` is provided as a Swift Package. You can add it to your project via [this repository's address](https://github.com/alladinian/Visionaire).

## Supported Vision Tasks

**All** Vision tasks are supported (up until **iOS 16** & **macOS 13**, which are the latest production releases).
<details>
<summary>
Expand to see a detailed list of all available tasks
</summary>

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
</details>

## Supported Image Sources
- `CGImage`
- `CIImage`
- `CVPixelBuffer`
- `CMSampleBuffer`
- `Data`
- `URL`

## Examples

The main class for interfacing is called `Visionaire`. 

It's an `ObservableObject` and reports processing through a published property called `isProcessing`.

You can execute tasks on the `shared` Visionaire singleton or on your own instance (useful if you want to have separate processors reporting on their own).

There are two sets of apis: convenience methods & task-based methods.

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

### Custom CoreML model (convenience apis):

```swift
	
	// Create an instance of your model
    let yolo: MLModel = {
        // Tell Core ML to use the Neural Engine if available.
        let config = MLModelConfiguration()
        config.computeUnits = .all
        // Load your custom model
        let yolo = try! yolo(configuration: config)
        return yolo.model
    }()
    
    // Optionally create a feature provider to setup custom model attributes
    class YoloFeatureProvider: MLFeatureProvider {
        var values: [String : MLFeatureValue] {
            [
                "iouThreshold": MLFeatureValue(double: 0.45),
                "confidenceThreshold": MLFeatureValue(double: 0.25)
            ]
        }

        var featureNames: Set<String> {
            Set(values.keys)
        }

        func featureValue(for featureName: String) -> MLFeatureValue? {
            values[featureName]
        }
    }
    
    // Perform the task
	let detectedObjectObservations = try visionaire.customRecognition(imageSource: image,
                                                                            model: try! VNCoreMLModel(for: yolo),
                                                            inputImageFeatureName: "image",
                                                                featureProvider: YoloFeatureProvider(),
                                                        imageCropAndScaleOption: .scaleFill)
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


## Task configuration

All tasks can be configured with "modifier" style calls for common options.

An example using all the available options:

```swift
let segmentation = VisionTask.personSegmentation(qualityLevel: .accurate)
    .preferBackgroundProcessing(true)
    .usesCPUOnly(false)
    .regionOfInterest(CGRect(x: 0, y: 0, width: 0.5, height: 0.5))
    .latestRevision() // You can also use .revision(n)

let result = try Visionaire.shared.perform([.horizonDetection, segmentation], on: image) // The result is a `VisionTaskResult`
```

## SwiftUI Extensions

There are also some SwiftUI extensions available in order to help you visualize results for quick evaluation.

**Detected Object Observations**

```swift
Image(myImage)
    .resizable()
    .aspectRatio(contentMode: .fit)
    .drawObservations(detectedObjectObservations) {
        Rectangle()
            .stroke(Color.blue, lineWidth: 2)
    }
```
![image](https://github.com/alladinian/Visionaire/assets/156458/70b4a0dd-dcf7-4c15-8ccb-cd37910e6a35)

**Rectangle Observations**

```swift
Image(myImage)
    .resizable()
    .aspectRatio(contentMode: .fit)
    .drawQuad(rectangleObservations) { shape in
        shape
            .stroke(Color.green, lineWidth: 2)
    }
```
![image](https://github.com/alladinian/Visionaire/assets/156458/9cc38998-e069-414b-8fae-bb5584ee48ec)

**Face Landmarks**

Note: For Face Landmarks you can specify individual characteristics or groups for visualization. The available options are available through the `FaceLandmarks` OptionSet and they are:

`constellation`, `contour`, `leftEye`, `rightEye`, `leftEyebrow`, `rightEyebrow`, `nose`, `noseCrest`, `medianLine`, `outerLips`, `innerLips`, `leftPupil`, `rightPupil`, `eyes`, `pupils`, `eyeBrows`, `lips` and `all`.

```swift
Image(myImage)
    .resizable()
    .aspectRatio(contentMode: .fit)
    .drawFaceLandmarks(faceObservations, landmarks: .all) { shape in
        shape
            .stroke(.red, style: .init(lineWidth: 2, lineJoin: .round))
    }
```
![image](https://github.com/alladinian/Visionaire/assets/156458/f63e6646-a2ce-4f82-bcdd-1ef30160ddb6)

**Person Segmentation Mask**

```swift
Image(myImage)
    .resizable()
    .aspectRatio(contentMode: .fit)
    .visualizePersonSegmentationMask(pixelBufferObservations)
```
![image](https://github.com/alladinian/Visionaire/assets/156458/72536049-3547-4c89-994c-4b46aee4e295)

**Human Body Pose**

```swift
Image(myImage)
    .resizable()
    .aspectRatio(contentMode: .fit)
    .visualizeHumanBodyPose(humanBodyPoseObservations) { shape in
        shape
            .fill(.red)
    }
```
![image](https://github.com/alladinian/Visionaire/assets/156458/dc56da48-ac80-4723-8403-dea660c73c20)

**Contours**

```swift
Image(myImage)
    .resizable()
    .aspectRatio(contentMode: .fit)
    .visualizeContours(contoursObservations) { shape in
        shape
            .stroke(.red, style: .init(lineWidth: 2, lineJoin: .round))
    }
```
![image](https://github.com/alladinian/Visionaire/assets/156458/ee4d9e63-3e37-494e-94d4-63ae2c72dc0a)



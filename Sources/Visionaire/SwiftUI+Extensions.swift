//
//  File.swift
//  
//
//  Created by Vasilis Akoinoglou on 5/7/23.
//

import SwiftUI
@preconcurrency import Vision

private extension View {
    func flipped(_ isFlipped: Bool) -> some View {
        scaleEffect(x: 1, y: isFlipped ? -1 : 1)
    }

    func frame(size: CGSize) -> some View {
        frame(width: size.width, height: size.height)
    }

    func offset(point: CGPoint) -> some View {
        offset(x: point.x, y: point.y)
    }
}

private extension Path {
    func flipped(_ isFlipped: Bool) -> some View {
        scaleEffect(x: 1, y: isFlipped ? -1 : 1)
    }
}

private extension CGRect {
    func flipped(_ isFlipped: Bool) -> CGRect {
        CGRect(origin: CGPoint(x: origin.x, y: isFlipped ? (1 - origin.y - size.height) : origin.y),
               size: size)
    }
}

public extension View {
    
    /// Places `VNDetectedObjectObservation` objects as an overlay.
    /// - Parameters:
    ///   - observations: The observation objects.
    ///   - isFlipped: Whether coordinate system is Y-Flipped. The default is `true`.
    ///   - drawingClosure: A closure providing the view to be drawn as a representation of the observation.
    /// - Returns: The overlay view.
    func drawObservations(_ observations: [VNDetectedObjectObservation], isFlipped: Bool = true, _ drawingClosure: @escaping (VNDetectedObjectObservation) -> some View) -> some View {
        overlay(
            GeometryReader { reader in
                ForEach(observations, id: \.self) { observation in
                    let denormalizedRect = VNImageRectForNormalizedRect(observation.boundingBox.flipped(isFlipped), Int(reader.size.width), Int(reader.size.height))
                    drawingClosure(observation)
                        .frame(size: denormalizedRect.size)
                        .offset(point: denormalizedRect.origin)
                }
            }
        )
    }
    
    /// Draws `VNFaceObservation` objects as an overlay.
    /// - Parameters:
    ///   - observations: The observation objects.
    ///   - landmarks: The face landmarks to be drawn.
    ///   - isFlipped: Whether coordinate system is Y-Flipped. The default is `true`.
    ///   - styleClosure: A closure that provides `Shape` objects for customization.
    /// - Returns: The overlay view.
    func drawFaceLandmarks(_ observations: [VNFaceObservation], landmarks: FaceLandmarks = .all, isFlipped: Bool = true, _ styleClosure: @escaping (VNFaceObservationShape) -> some View) -> some View  {
        overlay(
            styleClosure(VNFaceObservationShape(observations: observations, enabledLandmarks: landmarks))
                .flipped(isFlipped)
        )
    }
    
    /// Draws `VNRectangleObservation` objects as an overlay.
    /// - Parameters:
    ///   - observations: The observation objects.
    ///   - isFlipped: Whether coordinate system is Y-Flipped. The default is `true`.
    ///   - styleClosure: A closure that provides `Shape` objects for customization.
    /// - Returns: The overlay view.
    func drawQuad(_ observations: [VNRectangleObservation], isFlipped: Bool = true, _ styleClosure: @escaping (VNRectangleObservationShape) -> some View) -> some View  {
        overlay(
            styleClosure(VNRectangleObservationShape(observations: observations))
                .flipped(isFlipped)
        )
    }

    /// Visualizes a mask for a person segmentation.
    /// - Parameter observations: The observation objects.
    /// - Returns: The mask based on the observations.
    @ViewBuilder
    func visualizePersonSegmentationMask(_ observations: [VNPixelBufferObservation]) -> some View {
        if #available(iOS 15.0, macCatalyst 15.0, macOS 12.0, tvOS 15.0, *) {
           mask {
               PixelBufferObservationsCompositeMask(observations: observations)
            }
        } else {
            // Fallback on earlier versions
            mask(PixelBufferObservationsCompositeMask(observations: observations))
        }
    }

    /// Visualizes `VNHumanBodyPoseObservation` objects as an overlay.
    /// - Parameters:
    ///   - observations: The observation objects.
    ///   - isFlipped: Whether coordinate system is Y-Flipped. The default is `true`.
    ///   - styleClosure: A closure that provides `Shape` objects for customization.
    /// - Returns: The overlay view.
    @available(iOS 14.0, macCatalyst 14.0, macOS 11.0, tvOS 14.0, *)
    func visualizeHumanBodyPose(_ observations: [VNHumanBodyPoseObservation], isFlipped: Bool = true, dotsOnly: Bool = false, _ styleClosure: @escaping (VNHumanBodyPoseObservationShape) -> some View) -> some View {
        overlay(
            styleClosure(VNHumanBodyPoseObservationShape(observations: observations, dotsOnly: dotsOnly))
                .flipped(isFlipped)
        )
    }
    
    /// Visualizes `VNAnimalBodyPoseObservation` objects as an overlay.
    /// - Parameters:
    ///   - observations: The observation objects.
    ///   - isFlipped: Whether coordinate system is Y-Flipped. The default is `true`.
    ///   - styleClosure: A closure that provides `Shape` objects for customization.
    /// - Returns: The overlay view.
    @available(iOS 17.0, macCatalyst 17.0, macOS 14.0, tvOS 17.0, *)
    func visualizeAnimalBodyPose(_ observations: [VNAnimalBodyPoseObservation], dotsOnly: Bool = false, isFlipped: Bool = true, _ styleClosure: @escaping (VNAnimalBodyPoseObservationShape) -> some View) -> some View {
        overlay(
            styleClosure(VNAnimalBodyPoseObservationShape(observations: observations, dotsOnly: dotsOnly))
                .flipped(isFlipped)
        )
    }

    @available(iOS 14.0, macCatalyst 14.0, macOS 11.0, tvOS 14.0, *)
    func visualizeContours(_ observations: [VNContoursObservation], isFlipped: Bool = true, _ styleClosure: @escaping (VNContoursObservationShape) -> some View) -> some View {
        overlay(
            styleClosure(VNContoursObservationShape(observations: observations))
                .flipped(isFlipped)
        )
    }
}

/// A Shape constructed from `VNRectangleObservation` objects.
public struct VNRectangleObservationShape: Shape {
    let observations: [VNRectangleObservation]

    public func path(in rect: CGRect) -> Path {
        Path { path in
            for observation in observations {
                let points = [observation.bottomLeft, observation.topLeft, observation.topRight, observation.bottomRight].map {
                    VNImagePointForNormalizedPoint($0, Int(rect.size.width), Int(rect.size.height))
                }
                path.addLines(points)
                path.closeSubpath()
            }
        }
    }
}

@available(iOS 14.0, macCatalyst 14.0, macOS 11.0, tvOS 14.0, *)
public struct VNContoursObservationShape: Shape {
    let observations: [VNContoursObservation]

    public func path(in rect: CGRect) -> Path {
        Path { path in
            for observation in observations {
                let normalizedPath = observation.normalizedPath
                let transform = CGAffineTransform(scaleX: rect.width, y: rect.height)
                path.addPath(Path(normalizedPath), transform: transform)
            }
        }
    }
}

@available(iOS 14.0, macCatalyst 14.0, macOS 11.0, tvOS 14.0, *)
extension VNHumanBodyPoseObservation {
    
    func denormalizedPoints(_ jointNames: [VNHumanBodyPoseObservation.JointName], for size: CGSize) -> [CGPoint] {
        jointNames
            .compactMap { try? recognizedPoint($0) }
            .filter { $0.confidence > 0 }
            .map { $0.denormalizedForSize(size) }
    }
    
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, tvOS 17.0, *)
extension VNAnimalBodyPoseObservation {
    
    func denormalizedPoints(_ jointNames: [VNAnimalBodyPoseObservation.JointName], for size: CGSize) -> [CGPoint] {
        jointNames
            .compactMap { try? recognizedPoint($0) }
            .filter { $0.confidence > 0 }
            .map { $0.denormalizedForSize(size) }
    }
    
}

@available(iOS 14.0, macCatalyst 14.0, macOS 11.0, tvOS 14.0, *)
extension VNPoint {
    
    func denormalizedForSize(_ size: CGSize) -> CGPoint {
        VNImagePointForNormalizedPoint(location, Int(size.width), Int(size.height))
    }
    
}

/// A Shape constructed from `VNHumanBodyPoseObservation` objects.
@available(iOS 14.0, macCatalyst 14.0, macOS 11.0, tvOS 14.0, *)
public struct VNHumanBodyPoseObservationShape: Shape {
    let observations: [VNHumanBodyPoseObservation]
    let dotsOnly: Bool
    var dotSize = 4.0

    public func path(in rect: CGRect) -> Path {
        Path { path in
            for observation in observations {
                for group in observation.availableJointsGroupNames {
                    guard let recognizedPoints = try? observation.recognizedPoints(group) else {
                        continue
                    }

                    for (_, point) in recognizedPoints where point.confidence > 0 {
                        drawDot(for: point, in: &path, size: rect.size)
                    }
                }
                
                if !dotsOnly {
                    drawLine(for: observation, in: &path, size: rect.size)
                }
            }
        }
    }
    
    private func drawDot(for point: VNRecognizedPoint, in path: inout Path, size: CGSize) {
        let cgPoint = point.denormalizedForSize(size)
        let dotRect = CGRect(origin: cgPoint, size: .init(width: dotSize, height: dotSize)).offsetBy(dx: -dotSize / 2, dy: -dotSize / 2)
        path.addEllipse(in: dotRect)
    }
    
    private func drawLine(for observation: VNHumanBodyPoseObservation, in path: inout Path, size: CGSize) {
        // Right leg
        var points = observation.denormalizedPoints([.rightAnkle, .rightKnee, .rightHip, .root], for: size)
        path.addLines(points)
        
        // Left leg
        points = observation.denormalizedPoints([.leftAnkle, .leftKnee, .leftHip, .root], for: size)
        path.addLines(points)
        
        // Right arm
        points = observation.denormalizedPoints([.rightWrist, .rightElbow, .rightShoulder, .neck], for: size)
        path.addLines(points)
        
        // Left arm
        points = observation.denormalizedPoints([.leftWrist, .leftElbow, .leftShoulder, .neck], for: size)
        path.addLines(points)
        
        // Root to nose
        points = observation.denormalizedPoints([.root, .neck, .nose], for: size)
        path.addLines(points)
    }
}

/// A Shape constructed from `VNAnimalBodyPoseObservation` objects
@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, tvOS 17.0, *)
public struct VNAnimalBodyPoseObservationShape: Shape {
    let observations: [VNAnimalBodyPoseObservation]
    let dotsOnly: Bool
    var dotSize = 4.0

    public func path(in rect: CGRect) -> Path {
        Path { path in
            for observation in observations {
                for group in observation.availableJointGroupNames {
                    guard let recognizedPoints = try? observation.recognizedPoints(group) else {
                        continue
                    }

                    for (_, point) in recognizedPoints where point.confidence > 0 {
                        drawDot(for: point, in: &path, size: rect.size)
                    }
                }
                
                if !dotsOnly {
                    drawLine(for: observation, in: &path, size: rect.size)
                }
            }
        }
    }
    
    private func drawDot(for point: VNRecognizedPoint, in path: inout Path, size: CGSize) {
        let cgPoint = point.denormalizedForSize(size)
        let dotRect = CGRect(origin: cgPoint, size: .init(width: dotSize, height: dotSize)).offsetBy(dx: -dotSize / 2, dy: -dotSize / 2)
        path.addEllipse(in: dotRect)
    }
    
    private func drawLine(for observation: VNAnimalBodyPoseObservation, in path: inout Path, size: CGSize) {
        // Right back leg
        var points = observation.denormalizedPoints([.rightBackPaw, .rightBackKnee, .rightBackElbow, .tailBottom], for: size)
        path.addLines(points)
        
        // Right front leg
        points = observation.denormalizedPoints([.rightFrontPaw, .rightFrontKnee, .rightFrontElbow, .neck], for: size)
        path.addLines(points)
        
        // Left back leg
        points = observation.denormalizedPoints([.leftBackPaw, .leftBackKnee, .leftBackElbow, .tailBottom], for: size)
        path.addLines(points)
        
        // Left front leg
        points = observation.denormalizedPoints([.leftFrontPaw, .leftFrontKnee, .leftFrontElbow, .neck], for: size)
        path.addLines(points)
        
        // Left ear
        points = observation.denormalizedPoints([.leftEarTop, .leftEarMiddle, .leftEarBottom], for: size)
        path.addLines(points)
        
        // Right ear
        points = observation.denormalizedPoints([.rightEarTop, .rightEarMiddle, .rightEarBottom], for: size)
        path.addLines(points)
        
        // Tail
        points = observation.denormalizedPoints([.tailTop, .tailMiddle, .tailBottom], for: size)
        path.addLines(points)
        
        // Neck to Tail
        points = observation.denormalizedPoints([.neck, .tailBottom], for: size)
        path.addLines(points)
    }
}

/// A Shape constructed from `VNDetectedObjectObservation` objects
struct VNDetectedObjectObservationShape: Shape {
    let observations: [VNDetectedObjectObservation]

    func path(in rect: CGRect) -> Path {
        Path { path in
            for normalizedRect in observations.map({ $0.boundingBox }) {
                path.addRect(VNImageRectForNormalizedRect(normalizedRect, Int(rect.size.width), Int(rect.size.height)))
            }
        }
    }
}

/// A View constructed by stacking `CVPixelBuffer` based images suitable for masking (luminanceToAlpha)
public struct PixelBufferObservationsCompositeMask: View {
    let pixelBuffers: [CVPixelBuffer]
    
    public init(observations: [VNPixelBufferObservation]) {
        self.pixelBuffers = observations.map(\.pixelBuffer)
    }
    
    public init(pixelBuffers: [CVPixelBuffer]) {
        self.pixelBuffers = pixelBuffers
    }

    public var body: some View {
        if pixelBuffers.isEmpty {
            Color.black
        } else {
            ZStack {
                ForEach(pixelBuffers, id: \.self) { pixelBuffer in
                    PixelBufferImage(buffer: pixelBuffer)
                }
            }
            .luminanceToAlpha()
        }
    }
}

/// Presents an Image based on the contents of a `CVPixelBuffer`
public struct PixelBufferImage: View {
    let buffer: CVPixelBuffer
    
    public init(buffer: CVPixelBuffer) {
        self.buffer = buffer
    }

    public var body: some View {
        let image = CIImage(cvPixelBuffer: buffer)
        if let cgImage = kVisionaireContext.createCGImage(image, from: image.extent) {
            Image(cgImage, scale: 1, label: Text(""))
                .resizable()
        }
    }
}

/// A Shape constructed from `VNFaceObservation` objects
public struct VNFaceObservationShape: Shape {
    let observations: [VNFaceObservation]
    var enabledLandmarks: FaceLandmarks

    public func path(in rect: CGRect) -> Path {
        Path { path in
            for observation in observations {

                guard let landmarks = observation.landmarks else { return }

                let regions = landmarks.regionsFor(landmarks: enabledLandmarks)

                for region in regions {

                    let points = region.pointsInImage(imageSize: rect.size)

                    if #available(iOS 16.0, macOS 13.0, *) {
                        switch region.pointsClassification {

                        case .disconnected:
                            for point in points {
                                let dotSize = 4.0
                                let dotRect = CGRect(origin: point, size: .init(width: dotSize, height: dotSize)).offsetBy(dx: -dotSize / 2, dy: -dotSize / 2)
                                path.addEllipse(in: dotRect)
                            }

                        case .openPath:
                            path.addLines(points)

                        case .closedPath:
                            path.addLines(points)
                            path.closeSubpath()
                        }

                    } else {
                        path.addLines(points)
                        path.closeSubpath()
                    }
                }
            }
        }
    }
}


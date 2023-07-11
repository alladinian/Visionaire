//
//  File.swift
//  
//
//  Created by Vasilis Akoinoglou on 5/7/23.
//

import SwiftUI
import Vision

private extension View {
    func flipped(_ isFlipped: Bool) -> some View {
        scaleEffect(x: 1, y: isFlipped ? -1 : 1)
    }
}

public extension View {

    func drawObservations(_ observations: [VNDetectedObjectObservation], isFlipped: Bool = true, _ drawingClosure: @escaping () -> some View) -> some View {
        overlay(
            GeometryReader { reader in
                ForEach(observations, id: \.self) { observation in
                    let denormalizedRect = VNImageRectForNormalizedRect(observation.boundingBox, Int(reader.size.width), Int(reader.size.height))
                    drawingClosure()
                        .frame(width: denormalizedRect.size.width,
                               height: denormalizedRect.size.height)
                        .offset(x: denormalizedRect.origin.x,
                                y: denormalizedRect.origin.y)
                }
            }
            .flipped(isFlipped)
        )
    }

    func drawFaceLandmarks(_ observations: [VNFaceObservation], landmarks: FaceLandmarks = .all, isFlipped: Bool = true, _ styleClosure: @escaping (VNFaceObservationShape) -> some View) -> some View  {
        overlay(
            styleClosure(VNFaceObservationShape(observations: observations, enabledLandmarks: landmarks))
                .flipped(isFlipped)
        )
    }

    func drawQuad(_ observations: [VNRectangleObservation], isFlipped: Bool = true, _ styleClosure: @escaping (VNRectangleObservationShape) -> some View) -> some View  {
        overlay(
            styleClosure(VNRectangleObservationShape(observations: observations))
                .flipped(isFlipped)
        )
    }

    @ViewBuilder
    func visualizePersonSegmentationMask(_ observations: [VNPixelBufferObservation]) -> some View {
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, *) {
           mask {
               PixelBufferObservationsCompositeMask(observations: observations)
            }
        } else {
            // Fallback on earlier versions
            mask(PixelBufferObservationsCompositeMask(observations: observations))
        }
    }
}

public extension [VNDetectedObjectObservation] {
    func visionRects(isFlipped: Bool = true) -> some View {
        VNDetectedObjectObservationShape(observations: self)
            .flipped(isFlipped)
    }
}

/// A Shape constructed from `VNRectangleObservation` objects
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
struct PixelBufferObservationsCompositeMask: View {
    let observations: [VNPixelBufferObservation]

    var body: some View {
        if observations.isEmpty {
            Color.black
        } else {
            ZStack {
                ForEach(observations, id: \.self) { observation in
                    PixelBufferImage(buffer: observation.pixelBuffer)
                }
            }
            .luminanceToAlpha()
        }
    }
}

/// Presents an Image based on the contents of a `CVPixelBuffer`
struct PixelBufferImage: View {
    let buffer: CVPixelBuffer

    var body: some View {
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

                    if #available(iOS 16.0, macOS 13.0, tvOS 16, *) {
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

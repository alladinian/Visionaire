//
//  File.swift
//  
//
//  Created by Vasilis Akoinoglou on 5/7/23.
//

import SwiftUI
import Vision

public extension View {
    func drawObservations(_ observations: [VNDetectedObjectObservation], isFlipped: Bool = true, _ drawingClosure: @escaping (CGRect) -> some View) -> some View {
        overlay(
            GeometryReader { reader in
                ForEach(observations, id: \.self) { observation in
                    let denormalizedRect = VNImageRectForNormalizedRect(observation.boundingBox, Int(reader.size.width), Int(reader.size.height))
                    drawingClosure(denormalizedRect)
                        .frame(width: denormalizedRect.size.width,
                               height: denormalizedRect.size.height)
                        .offset(x: denormalizedRect.origin.x,
                                y: denormalizedRect.origin.y)
                }
            }
            .scaleEffect(x: 1, y: isFlipped ? -1 : 1)
        )
    }
}

public extension [VNDetectedObjectObservation] {
    func visionRects(isFlipped: Bool = true) -> some Shape {
        DetectorRectangles(observations: self).scale(x: 1, y: isFlipped ? -1 : 1)
    }
}

struct DetectorRectangles: Shape {
    let observations: [VNDetectedObjectObservation]

    func path(in rect: CGRect) -> Path {
        Path { path in
            for normalizedRect in observations.map({ $0.boundingBox }) {
                path.addRect(VNImageRectForNormalizedRect(normalizedRect, Int(rect.size.width), Int(rect.size.height)))
            }
        }
    }
}

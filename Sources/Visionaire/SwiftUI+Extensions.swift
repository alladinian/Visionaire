//
//  File.swift
//  
//
//  Created by Vasilis Akoinoglou on 5/7/23.
//

import SwiftUI
import Vision

public extension View {

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

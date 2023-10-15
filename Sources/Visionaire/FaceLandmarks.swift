//
//  FaceLandmarks.swift
//  
//
//  Created by Vasilis Akoinoglou on 5/7/23.
//

import Foundation
import Vision

public struct FaceLandmarks: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let constellation = FaceLandmarks(rawValue: 1 << 0) // Constellation

    public static let contour       = FaceLandmarks(rawValue: 1 << 1)

    public static let leftEye       = FaceLandmarks(rawValue: 1 << 2)
    public static let rightEye      = FaceLandmarks(rawValue: 1 << 3)

    public static let leftEyebrow   = FaceLandmarks(rawValue: 1 << 4)
    public static let rightEyebrow  = FaceLandmarks(rawValue: 1 << 5)

    public static let nose          = FaceLandmarks(rawValue: 1 << 6)
    public static let noseCrest     = FaceLandmarks(rawValue: 1 << 7)

    public static let medianLine    = FaceLandmarks(rawValue: 1 << 8)

    public static let outerLips     = FaceLandmarks(rawValue: 1 << 9)
    public static let innerLips     = FaceLandmarks(rawValue: 1 << 10)

    public static let leftPupil     = FaceLandmarks(rawValue: 1 << 11)
    public static let rightPupil    = FaceLandmarks(rawValue: 1 << 12)

    public static let eyes: FaceLandmarks     = [.leftEye, .rightEye]
    public static let pupils: FaceLandmarks   = [.leftPupil, .rightPupil]
    public static let eyeBrows: FaceLandmarks = [.leftEyebrow, .rightEyebrow]
    public static let lips: FaceLandmarks     = [.innerLips, .outerLips]

    public static let all: FaceLandmarks = [.contour, .eyes, .eyeBrows, .nose, .noseCrest, .medianLine, .lips, .pupils]
}

public extension VNFaceLandmarks2D {
    func regionsFor(landmarks: FaceLandmarks) -> [VNFaceLandmarkRegion2D] {

        if landmarks == .constellation {
            return [allPoints ?? nil].compactMap { $0 }
        }

        var regions: [VNFaceLandmarkRegion2D?] = []

        if landmarks.contains(.contour) {
            regions.append(faceContour)
        }

        if landmarks.contains(.leftEye) {
            regions.append(leftEye)
        }

        if landmarks.contains(.rightEye) {
            regions.append(rightEye)
        }

        if landmarks.contains(.leftEyebrow) {
            regions.append(leftEyebrow)
        }

        if landmarks.contains(.rightEyebrow) {
            regions.append(rightEyebrow)
        }

        if landmarks.contains(.nose) {
            regions.append(nose)
        }

        if landmarks.contains(.noseCrest) {
            regions.append(noseCrest)
        }

        if landmarks.contains(.medianLine) {
            regions.append(medianLine)
        }

        if landmarks.contains(.outerLips) {
            regions.append(outerLips)
        }

        if landmarks.contains(.innerLips) {
            regions.append(innerLips)
        }

        if landmarks.contains(.leftPupil) {
            regions.append(leftPupil)
        }

        if landmarks.contains(.rightPupil) {
            regions.append(rightPupil)
        }

        return regions.compactMap { $0 }
    }
}

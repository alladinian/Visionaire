//
//  Geometry.swift
//  
//
//  Created by Vasilis Akoinoglou on 6/12/23.
//

import Foundation
import SwiftUI

extension View {
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

extension Path {
    func flipped(_ isFlipped: Bool) -> some View {
        scaleEffect(x: 1, y: isFlipped ? -1 : 1)
    }
}

public extension CGRect {
    func flipped(_ isFlipped: Bool) -> CGRect {
        CGRect(origin: CGPoint(x: origin.x, y: isFlipped ? (1 - origin.y - size.height) : origin.y),
               size: size)
    }
}

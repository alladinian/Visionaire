//
//  VisionTaskResult.swift
//  
//
//  Created by Vasilis Akoinoglou on 5/7/23.
//

import Foundation
import Vision

//MARK: - Task Result Wrapper
public struct VisionTaskResult {
    public let request: VNRequest
    public let observations: [VNObservation]

    init(_ request: VNRequest) {
        self.request      = request
        self.observations = request.results ?? []
    }
}

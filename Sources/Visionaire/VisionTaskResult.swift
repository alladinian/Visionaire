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
    public let error: Error?

    init(request: VNRequest, error: Error?) {
        self.request      = request
        self.observations = request.results ?? []
        self.error        = error
    }
}

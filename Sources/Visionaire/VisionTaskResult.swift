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
    public let taskType: VisionTaskType
    public let request: VNRequest
    public let observations: [VNObservation]

    init(_ task: VisionTask) {
        self.taskType     = task.taskType
        self.request      = task.request
        self.observations = task.request.results ?? []
    }
}

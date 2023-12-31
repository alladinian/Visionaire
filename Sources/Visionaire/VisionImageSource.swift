//
//  VisionImageSource.swift
//  
//
//  Created by Vasilis Akoinoglou on 30/7/23.
//

import Foundation
import Vision
import CoreImage

public protocol VisionImageSource {
    func VNImageHandler(orientation: CGImagePropertyOrientation?, context: CIContext?) -> VNImageRequestHandler
    func VNTargetedImageRequest<T: VNTargetedImageRequest>(orientation: CGImagePropertyOrientation?, context: CIContext?) -> T
}

private func optionsForContext(_ context: CIContext?) -> [VNImageOption : Any] {
    [.ciContext: context ?? kVisionaireContext]
}

//MARK: - Image Handlers

extension CGImage: VisionImageSource {
    public func VNImageHandler(orientation: CGImagePropertyOrientation? = nil, context: CIContext? = nil) -> VNImageRequestHandler {
        if let orientation {
            return VNImageRequestHandler(cgImage: self, orientation: orientation, options: optionsForContext(context))
        } else {
            return VNImageRequestHandler(cgImage: self, options: optionsForContext(context))
        }
    }

    public func VNTargetedImageRequest<T>(orientation: CGImagePropertyOrientation? = nil, context: CIContext? = nil) -> T where T : VNTargetedImageRequest {
        if let orientation {
            return T(targetedCGImage: self, orientation: orientation, options: optionsForContext(context))
        } else {
            return T(targetedCGImage: self, options: optionsForContext(context))
        }
    }
}

extension CIImage: VisionImageSource {
    public func VNImageHandler(orientation: CGImagePropertyOrientation? = nil, context: CIContext? = nil) -> VNImageRequestHandler {
        if let orientation {
            return VNImageRequestHandler(ciImage: self, orientation: orientation, options: optionsForContext(context))
        } else {
            return VNImageRequestHandler(ciImage: self, options: optionsForContext(context))
        }
    }

    public func VNTargetedImageRequest<T>(orientation: CGImagePropertyOrientation? = nil, context: CIContext? = nil) -> T where T : VNTargetedImageRequest {
        if let orientation {
            return T(targetedCIImage: self, orientation: orientation, options: optionsForContext(context))
        } else {
            return T(targetedCIImage: self, options: optionsForContext(context))
        }
    }
}

extension CVPixelBuffer: VisionImageSource {
    public func VNImageHandler(orientation: CGImagePropertyOrientation? = nil, context: CIContext? = nil) -> VNImageRequestHandler {
        if let orientation {
            return VNImageRequestHandler(cvPixelBuffer: self, orientation: orientation, options: optionsForContext(context))
        } else {
            return VNImageRequestHandler(cvPixelBuffer: self, options: optionsForContext(context))
        }
    }

    public func VNTargetedImageRequest<T>(orientation: CGImagePropertyOrientation? = nil, context: CIContext? = nil) -> T where T : VNTargetedImageRequest {
        if let orientation {
            return T(targetedCVPixelBuffer: self, orientation: orientation, options: optionsForContext(context))
        } else {
            return T(targetedCVPixelBuffer: self, options: optionsForContext(context))
        }
    }
}

@available(macOS 11.0, iOS 14.0, *)
extension CMSampleBuffer: VisionImageSource {
    public func VNImageHandler(orientation: CGImagePropertyOrientation? = nil, context: CIContext? = nil) -> VNImageRequestHandler {
        if let orientation {
            return VNImageRequestHandler(cmSampleBuffer: self, orientation: orientation, options: optionsForContext(context))
        } else {
            return VNImageRequestHandler(cmSampleBuffer: self, options: optionsForContext(context))
        }
    }

    public func VNTargetedImageRequest<T>(orientation: CGImagePropertyOrientation? = nil, context: CIContext? = nil) -> T where T : VNTargetedImageRequest {
        if let orientation {
            return T(targetedCMSampleBuffer: self, orientation: orientation, options: optionsForContext(context))
        } else {
            return T(targetedCMSampleBuffer: self, options: optionsForContext(context))
        }
    }
}

extension Data: VisionImageSource {
    public func VNImageHandler(orientation: CGImagePropertyOrientation? = nil, context: CIContext? = nil) -> VNImageRequestHandler {
        if let orientation {
            return VNImageRequestHandler(data: self, orientation: orientation, options: optionsForContext(context))
        } else {
            return VNImageRequestHandler(data: self, options: optionsForContext(context))
        }
    }

    public func VNTargetedImageRequest<T>(orientation: CGImagePropertyOrientation? = nil, context: CIContext? = nil) -> T where T : VNTargetedImageRequest {
        if let orientation {
            return T(targetedImageData: self, orientation: orientation, options: optionsForContext(context))
        } else {
            return T(targetedImageData: self, options: optionsForContext(context))
        }
    }
}

extension URL: VisionImageSource {
    public func VNImageHandler(orientation: CGImagePropertyOrientation? = nil, context: CIContext? = nil) -> VNImageRequestHandler {
        if let orientation {
            return VNImageRequestHandler(url: self, orientation: orientation, options: optionsForContext(context))
        } else {
            return VNImageRequestHandler(url: self, options: optionsForContext(context))
        }
    }

    public func VNTargetedImageRequest<T>(orientation: CGImagePropertyOrientation? = nil, context: CIContext? = nil) -> T where T : VNTargetedImageRequest {
        if let orientation {
            return T(targetedImageURL: self, orientation: orientation, options: optionsForContext(context))
        } else {
            return T(targetedImageURL: self, options: optionsForContext(context))
        }
    }
}

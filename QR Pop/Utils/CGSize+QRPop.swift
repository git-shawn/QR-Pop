//
//  CGSize+QRPop.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/14/23.
//

import Foundation

extension CGSize {
    
    
    /// Scales this size to a percentage of another size while maintaining aspect ratio.
    /// - Parameters:
    ///   - bounds: The bounds to fit into.
    ///   - percentOfBounds: The percentage of the parent bounds to be scaled ot.
    /// - Returns: The scaled `CGSize`.
    func scaling(intoBounds bounds: CGSize, by percentOfBounds: CGFloat) -> CGSize {
        
        let widthRatio = bounds.width / width
        let heightRatio = bounds.height / height
        let aspectRatio = min(widthRatio, heightRatio)
        
        let scaledSizeInBounds = CGSize(
            width: (width * aspectRatio) * percentOfBounds,
            height: (height * aspectRatio) * percentOfBounds
        )
        
        return scaledSizeInBounds
    }
    
    /// Scales this size to another size while maintaining aspect ratio.
    /// - Parameter bounds: The bounds to fit into.
    /// - Returns: The scaled `CGSize`.
    func scaling(intoBounds bounds: CGSize) -> CGSize {
        
        let widthRatio = bounds.width / width
        let heightRatio = bounds.height / height
        let aspectRatio = min(widthRatio, heightRatio)
        
        let scaledSizeInBounds = CGSize(
            width: (width * aspectRatio),
            height: (height * aspectRatio)
        )
        
        return scaledSizeInBounds
    }
}

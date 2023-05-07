//
//  Image+Position.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/14/23.
//

import SwiftUI
import OSLog

#if canImport(UIKit) && canImport(CoreImage)
import UIKit

extension UIImage {
    
    // MARK: UIImage Rotate
    /// Rotate a square image about its origin an angle, in degrees, of either 90, 180, 270, or 360.
    /// - Parameter degrees: An angle, in degrees, that is an increment of 90.
    /// - Returns: The image, rotated about its origin.
    /// - Credit: https://stackoverflow.com/a/47402811/20422552
    func rotate(by clockwiseRotation: ClockwiseRotation) -> UIImage? {
        var angle: Angle {
            if clockwiseRotation == .clockwise {
                return Angle(degrees: 90)
            } else {
                return Angle(degrees: 270)
            }
        }
        
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(angle.radians))).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            Logger.logModel.error("UIImage: Could not get current UIGraphicsContext to perform rotation.")
            return nil
        }
        
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        context.rotate(by: CGFloat(angle.radians))
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // MARK: UIImage Resize
    /// Returns a resized image.
    /// - Parameter size: The new size.
    /// - Returns: The image at a new size.
    func resized(to size: CGSize) throws -> UIImage {
        guard let result = self.preparingThumbnail(of: size) else {
            Logger.logModel.error("UIImage: Could not prepare thumbnail for image.")
            throw PlatformImageError.drawError
        }
        return result
    }
    
    // MARK: UIImage Place
    /// Places an image within a transparent rectangle of a specified size at a specified percentage of the total size.
    /// - Parameters:
    ///   - rectOfSize: The size of the transparent rectangular field.
    ///   - position: The placement of this image within the field.
    ///   - percent: The percentage of the total field size to scale this image to.
    /// - Returns: A transparent image.
    func place(in rectOfSize: CGSize, at position: DesignModel.PlacementPosition, scaledBy percent: Double = 0.2) throws -> UIImage {
        let scaledSize = self.size.scaling(intoBounds: rectOfSize, by: percent)
        
        var newPosition: CGPoint {
            if position == .center {
                let centerX = (rectOfSize.width/2 - scaledSize.width/2)
                let centerY = (rectOfSize.height/2 - scaledSize.height/2)
                return CGPoint(x: centerX, y: centerY)
            } else {
                let largestDimension = max(scaledSize.width, scaledSize.height)
                let bottomTrailingX = ((rectOfSize.width - largestDimension) - (rectOfSize.width * 0.1))
                let bottomTrailingY = ((rectOfSize.height - largestDimension) - (rectOfSize.height * 0.1))
                
                return CGPoint(x: bottomTrailingX, y: bottomTrailingY)
            }
        }
        
        let placementRect = CGRectIntegral(CGRect(origin: newPosition, size: scaledSize))
        
        UIGraphicsBeginImageContextWithOptions(rectOfSize, false, 0)
        self.draw(in: placementRect)
        guard let placedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            Logger.logModel.error("UIImage: Could not get an image from UIGraphicsContext.")
            throw PlatformImageError.drawError
        }
        UIGraphicsEndImageContext()
        
        return placedImage
    }
    
    // MARK: - UIImage Stroke Edges
    /// Converts this image into an edge outline of a certain width.
    /// - Parameter lineWidthPercentage: How thick the stroke should be,
    /// as a percentage of the image's smallest dimension.
    /// - Returns: An outline of the image's edges.
    func strokeEdges(by lineWidthPercentage: Double) throws -> UIImage {
        guard let coreImage = CIImage(image: self)
        else {
            Logger.logModel.error("UIImage: Could not create CIImage.")
            throw PlatformImageError.drawError
        }
        
        let edges = coreImage.applyingFilter("CIEdges", parameters: [
            kCIInputIntensityKey: 10.0
         ])
        
        let borderWidth = lineWidthPercentage * min(coreImage.extent.width, coreImage.extent.height)
        
        let widenedEdges = edges.applyingFilter("CIMorphologyMaximum", parameters: [
            kCIInputRadiusKey: borderWidth
        ])
        
        let background = widenedEdges.applyingFilter("CIMaskToAlpha")
        let context = CIContext(options: nil)
        guard let cgImageRef = context.createCGImage(background, from: background.extent) else {
            Logger.logModel.error("UIImge: Could not create CGImage from CIImage.")
            throw PlatformImageError.drawError
        }
        return UIImage(cgImage: cgImageRef)
    }
    
    enum ClockwiseRotation {
        case clockwise, counterclockwise
    }
}

#elseif canImport(AppKit)
import AppKit

extension NSImage {
    
    //MARK: - NSImage Rotate
    /// Rotate a square image about its origin an angle, in degrees, of either 90, 180, 270, or 360.
    /// - Parameter degrees: An angle, in degrees, that is an increment of 90.
    /// - Returns: The image, rotated about its origin.
    func rotate(by clockwiseRotation: ClockwiseRotation) -> NSImage? {
        var angle: Angle {
            if clockwiseRotation == .clockwise {
                return Angle(degrees: 270)
            } else {
                return Angle(degrees: 90)
            }
        }
        var imageBounds = NSZeroRect ; imageBounds.size = self.size
        let pathBounds = NSBezierPath(rect: imageBounds)
        let transform = NSAffineTransform()
        transform.rotate(byDegrees: angle.degrees)
        pathBounds.transform(using: transform as AffineTransform)
        
        let rotatedBounds = NSRect(origin: .zero, size: pathBounds.bounds.size)
        
        imageBounds.origin.x = rotatedBounds.midX - imageBounds.width/2
        imageBounds.origin.y = rotatedBounds.midY - imageBounds.height/2
        
        
        let rotatedImage = NSImage(size: rotatedBounds.size, flipped: false, drawingHandler: { (rect) -> Bool in
            let transform = NSAffineTransform()
            transform.translateX(by: rotatedBounds.width/2, yBy: rotatedBounds.height/2)
            transform.rotate(byRadians: CGFloat(angle.radians))
            transform.translateX(by: -rotatedBounds.width/2, yBy: -rotatedBounds.height/2)
            transform.concat()
            self.draw(in: imageBounds)
            return true
        })
        
        return rotatedImage
    }
    
    //MARK: - NSImage Resize
    /// Returns a resized image.
    /// - Parameter size: The new size.
    /// - Returns: The image at a new size.
    func resized(to size: CGSize) throws -> NSImage {
        let scaledSize = self.size.scaling(intoBounds: size)
        let centerPoint = NSPoint(x: size.width/2-scaledSize.width/2, y: size.height/2-scaledSize.height/2)
        let drawingRect = NSRect(origin: centerPoint, size: scaledSize)
        
        let resizedImage = NSImage(size: size, flipped: false, drawingHandler: { (rect) -> Bool in
            self.draw(in: drawingRect)
            return true
        })
        
        return resizedImage
    }
    
    // MARK: NSImage Place
    /// Places an image within a transparent rectangle of a specified size at a specified percentage of the total size.
    /// - Parameters:
    ///   - rectOfSize: The size of the transparent rectangular field.
    ///   - position: The placement of this image within the field.
    ///   - percent: The percentage of the total field size to scale this image to.
    /// - Returns: A transparent image.
    func place(in rectOfSize: CGSize, at position: DesignModel.PlacementPosition, scaledBy percent: Double = 0.2) throws -> NSImage {
        let scaledSize = self.size.scaling(intoBounds: rectOfSize, by: percent)
        
        var newPosition: CGPoint {
            if position == .center {
                let centerX = (rectOfSize.width/2 - scaledSize.width/2)
                let centerY = (rectOfSize.height/2 - scaledSize.height/2)
                return CGPoint(x: centerX, y: centerY)
            } else {
                let largestDimension = max(scaledSize.width, scaledSize.height)
                let bottomTrailingX = (rectOfSize.width - (largestDimension + rectOfSize.width * 0.1))
                let bottomTrailingY = (largestDimension - rectOfSize.height * 0.1)
                
                return CGPoint(x: bottomTrailingX, y: bottomTrailingY)
            }
        }
        
        let placementRect = CGRectIntegral(CGRect(origin: newPosition, size: scaledSize))
        
        let placedImage = NSImage(size: rectOfSize, flipped: false, drawingHandler: { rect in
            self.draw(in: placementRect, from: NSRect(origin: .zero, size: self.size), operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            return true
        })
        
        return placedImage
    }
    
    // MARK: - NSImage Stroke Edges
    /// Converts this image into an edge outline of a certain width.
    /// - Parameter lineWidthPercentage: How thick the stroke should be,
    /// as a percentage of the image's smallest dimension.
    /// - Returns: An outline of the image's edges.
    func strokeEdges(by lineWidthPercentage: Double) throws -> NSImage {
        guard let cgImage = self.cgImage
        else {
            Logger.logModel.error("NSImage: NSImage does not have member CGImage.")
            throw PlatformImageError.drawError
        }
        
        let coreImage = CIImage(cgImage: cgImage)
        
        let edges = coreImage.applyingFilter("CIEdges", parameters: [
            kCIInputIntensityKey: 10.0
         ])
        
        let borderWidth = lineWidthPercentage * min(coreImage.extent.width, coreImage.extent.height)
        
        let widenedEdges = edges.applyingFilter("CIMorphologyMaximum", parameters: [
            kCIInputRadiusKey: borderWidth
        ])
        
        let background = widenedEdges.applyingFilter("CIMaskToAlpha")
        let context = CIContext(options: nil)
        guard let cgImageRef = context.createCGImage(background, from: background.extent) else {
            Logger.logModel.error("NSImage: CIImage could not be converted to CIImage.")
            throw PlatformImageError.drawError
        }
        return NSImage(cgImage: cgImageRef)
    }
    
    enum ClockwiseRotation {
        case clockwise, counterclockwise
    }
}

#endif

#if !EXTENSION && !CLOUDEXT

// MARK: - Previews

struct NSImageExtensions_Previews: PreviewProvider {
    static var previews: some View {
        let image = PlatformImage(named: "Mudkip")
        
        Grid {
            GridRow {
                
                VStack {
                    if let resizedImage = try? image?.resized(to: CGSize(width: 60, height: 60)) {
                        Image(platformImage: resizedImage)
                            .frame(width: 120, height: 120)
                        Text("Resized Image")
                    }
                }
                
                VStack {
                    if let maskedImage = try? image?.strokeEdges(by: 0.01) {
                        Image(platformImage: maskedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .colorMultiply(.red)
                        Text("Edge Detector")
                    }
                }
                
                VStack {
                    
                    if let maskedImage = try? image?.strokeEdges(by: 0.05) {
                        ZStack {
                            Image(platformImage: maskedImage)
                                .resizable()
                                .colorMultiply(.black)
                                .scaledToFit()
                            Image(platformImage: image!)
                                .resizable()
                                .scaledToFit()
                                .padding(6)
                        }
                        .frame(width: 120, height: 120)
                        Text("Image with Stroke")
                    }
                }
                
            }
            
            GridRow {
                
                VStack {
                    if
                        let btPlacedImage = try? image?.place(in: CGSize(width: 240, height: 240), at: .bottomTrailing, scaledBy: 0.25),
                        let cPlacedImage = try? image?.place(in: CGSize(width: 240, height: 240), at: .center, scaledBy: 0.25)
                    {
                        ZStack {
                            Image(platformImage: btPlacedImage)
                                .resizable()
                                .scaledToFit()
                            Image(platformImage: cPlacedImage)
                                .resizable()
                                .scaledToFit()
                        }
                        .overlay(
                            Rectangle()
                                .stroke(.secondary, lineWidth: 1)
                        )
                        Text("Placed Image")
                    }
                }
                .frame(width: 120, height: 120)
                
                VStack {
                    if let rotatedImage = image?.rotate(by: .counterclockwise) {
                        Image(platformImage: rotatedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                        Text("Rotated Image \(Image(systemName: "arrow.counterclockwise"))")
                    }
                }
                
                VStack {
                    if let rotatedImage = image?.rotate(by: .clockwise) {
                        Image(platformImage: rotatedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                        Text("Rotated Image \(Image(systemName: "arrow.clockwise"))")
                    }
                }
                
            }
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
        .previewInterfaceOrientation(.landscapeRight)
    }
}

#endif

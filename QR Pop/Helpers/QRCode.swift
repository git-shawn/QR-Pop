//
//  QRCode.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import Foundation
import SwiftUI
import Contacts
import Combine
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class QRCode: NSObject, ObservableObject {
    @AppStorage("errorCorrection") private var errorLevel: Int = 0
    @Published var codeContent: String = ""
    @Published var backgroundColor: Color = .white
    @Published var foregroundColor: Color = .black
    
    /// PNG Data of the QR code generated.
    @Published var imgData: Data
    
    override init() {
        imgData = "".data(using: .utf8)!
        super.init()
        generate()
    }
    
    /// Resets the QRCode object to default settings.
    func reset() {
        codeContent = ""
        backgroundColor = .white
        foregroundColor = .black
        generate()
    }
    
    /// Generate a QR code.
    /// - Note: If the background color, foreground color, and data is not set in the QRCode object, an empty black and white code will be generated.
    /// - Warning: All codes are now generated using UTF8 encoding and cannot exceed 2000 characters of data.
    /// - Returns: PNG Data of a QR code.
    func generate() {
        // Too much data will cause the CIFilter to fail.
        if codeContent.count > 2000 {
            print("Error, excessive data sent to QRCode.swift. UTF8 encoded data should not exceed 2000 characters.")
            imgData = errorImgData()
        }
        
        // Create the CIFilter to make the QR code
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            print("Error initiating CIQRCodeGenerator CIFilter")
            return imgData = errorImgData()
        }

        // Encode the data
        guard let qrData = codeContent.data(using: .utf8) else {
            print("Error encoding content string. Invalid String likely passed to QRCode.generate().")
            return imgData = errorImgData()
        }
        qrFilter.setDefaults()
        qrFilter.setValue(qrData, forKey: "inputMessage")
        
        // Apply the error correction level chosen by the user, or L (7%) by default.
        switch errorLevel {
        // 7% error correction
        case 0:
            qrFilter.setValue("L", forKey: "inputCorrectionLevel")
        // 15% error correction
        case 1:
            qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        // 25% error correction
        case 2:
            qrFilter.setValue("Q", forKey: "inputCorrectionLevel")
        // 30% error correction
        case 3:
            qrFilter.setValue("H", forKey: "inputCorrectionLevel")
        default:
            qrFilter.setValue("L", forKey: "inputCorrectionLevel")
        }

        // Create the CIFilter to colorize the QR code
        guard let colorFilter = CIFilter(name: "CIFalseColor") else {
            print("Error initiating CIFalseColor CIFilter")
            return imgData = errorImgData()
        }

        // Apply color to the QR Code
        colorFilter.setDefaults()
        colorFilter.setValue(qrFilter.outputImage, forKey: "inputImage")
        colorFilter.setValue(colorToCIColor(color: foregroundColor), forKey: "inputColor0")
        colorFilter.setValue(colorToCIColor(color: backgroundColor), forKey: "inputColor1")
        
        guard let ciImage = colorFilter.outputImage else {
            print("Error generating output image for QR code in QRCode.swift.")
            return imgData = errorImgData()
        }
        
        // Scale the QR code so that it looks nice on retina displays
        let transform = CGAffineTransform(scaleX: 25, y: 25)
        let scaledCIImage = ciImage.transformed(by: transform)
        
        // Convert the data to an NSImage
        let ciData = ciImgToData(image: scaledCIImage)
        
        imgData = ciData
    }
    
    #if os(iOS)
     /// Generate a vCard from a Contact.
     /// - Parameter contact: The contact to transform into a vCard.
     /// - Returns: The vCard data as a String. If error, returns nil.
     private func vcard(contact: CNContact) -> String? {
         var data = Data()
         let contactStore = CNContactStore()
         var fetchedContact = contact
         do {
             try fetchedContact = contactStore.unifiedContact(withIdentifier: contact.identifier, keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
         } catch {
             return nil
         }
         do {
             try (data = CNContactVCardSerialization.data(with: [fetchedContact]))
             let contactString = String(decoding: data, as: UTF8.self)
             return contactString
         } catch {
             return nil
         }
     }
    #else
    /// Generate a vCard from a Contact.
    /// - Parameter contact: The contact to transform into a vCard.
    /// - Returns: The vCard data as a String. If error, returns nil.
    private func vcard(contact: CNContact) -> String? {
        var data = Data()
        let contactStore = CNContactStore()
        var fetchedContact = contact
        do {
            try fetchedContact = contactStore.unifiedContact(withIdentifier: contact.identifier, keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
        } catch {
            return nil
        }
        do {
            try (data = CNContactVCardSerialization.data(with: [fetchedContact]))
            let contactString = String(decoding: data, as: UTF8.self)
            return contactString
        } catch {
            return nil
        }
    }
    #endif
     
    /// Generates a QR code for a given contact.
    /// - Parameters:
    ///   - contact: The CNContact to convert to a QR code.
    ///   - bg: The background color for the QR code.
    ///   - fg: The foregroound color for the QR code.
    ///   - correction: Optional, the error correction level for the QR code.
    /// - Returns: An image of  the QR code generated.
    func generateContact(contact: CNContact) {
        let vcard: String? = self.vcard(contact: contact)
        guard vcard != nil else {return imgData = errorImgData()}
        codeContent = vcard!
        generate()
    }
    
    /// Set the data to be encoded into the QR code.
    /// - Parameter string: The String to be encoded.
    func setContent(string: String) {
        codeContent = string
        generate()
    }
    
    /// Get the content encoded in the QR Code.
    /// - Returns: The String encoded.
    func getContent() -> String {
        return codeContent
    }

    /// Converts a CIImage to PNG Data on iOS and macOS
    /// - Parameter image: The CIImage to convert
    /// - Returns: PNG Data of the CIImage
    private func ciImgToData(image: CIImage) -> Data {
        #if os(macOS)
        let rep = NSCIImageRep(ciImage: image)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage.png!
        #else
        let uiimage = UIImage(ciImage: image)
        return uiimage.pngData()!
        #endif
    }
    
    /// Create PNG data for the QR code generator error image on iOS and macOS
    /// - Returns: PNG Data for the error image
    private func errorImgData() -> Data {
        #if os(macOS)
        let nsimage = NSImage(imageLiteralResourceName: "codeFailure")
        return nsimage.png!
        #else
        let uiimage = UIImage(named: "codeFailure")
        return uiimage!.pngData()!
        #endif
    }
    
    /// Converts a SwiftUI Color to CIColor on iOS and macOS
    /// - Parameter color: The SwiftUI Color to convert
    /// - Returns: `color` as a CIColor
    private func colorToCIColor(color: Color) -> CIColor {
        #if os(macOS)
        return CIColor(color: NSColor(color))!
        #else
        return CIColor(color: UIColor(color))
        #endif
    }
}

//MARK: - Image to Data Conversion Functions

#if os(macOS)
extension NSBitmapImageRep {
    var png: Data? { representation(using: .png, properties: [:]) }
}
extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}
extension NSImage {
    var png: Data? { tiffRepresentation?.bitmap?.png }
}
#endif

#if os(iOS)
extension UIImage {
    var imageSizeInKB: Double { Double((pngData()!.count/1000)) }
}
#endif

//MARK: - Image Overlay Functions

#if os(iOS)
extension UIImage {
    
    /// Overlay an image with another image. The overlaying image will be centered and a quarter the size of the initial image.
    /// - Parameter overlay: The image to overlay
    /// - Returns: A new image, created as a merger of the initial image and the overlay.
    /// - Warning: If being used for a QR Code, the code's error correction must be as high as possible.
    func overlayWith(overlay: UIImage, bgColor: Color) -> UIImage {
        let initialImage = self

        UIGraphicsBeginImageContext(size)

        // The initial size of the QR code
        let codeSize = CGRect(x: 0, y: 0, width: initialImage.size.width, height: initialImage.size.height)
        // The size of the overlaying image, which is 25% the size of the QR code.
        let overlaySize = CGRect(x: ((initialImage.size.width * 0.5)-(initialImage.size.width * 0.125)), y: ((initialImage.size.width * 0.5)-(initialImage.size.width * 0.125)), width: (initialImage.size.width * 0.25), height: (initialImage.size.width * 0.25))
        
        let croppedOverlay = overlay.cropToBounds(width: (initialImage.size.width * 0.5), height: (initialImage.size.height * 0.5))
        let solidImage = croppedOverlay.imageWithColor(backgroundColor: UIColor(bgColor))
        
        initialImage.draw(in: codeSize)
        solidImage.draw(in: overlaySize, blendMode: .normal, alpha: 1.0)

        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return mergedImage
    }
    
    /// Crop an image to bounds programatically.
    /// By Cole at https://stackoverflow.com/a/32041649
    /// - Parameters:
    ///   - image: The UIImage to be cropped
    ///   - width: The new width
    ///   - height: The new height
    /// - Returns: The cropped UIImage
    func cropToBounds(width: Double, height: Double) -> UIImage {
        let image = self
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)

        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }

        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!

        // Create a new image based on the imageRef and rotate back to the original orientation
        let newImage: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

        return newImage
    }
    
    func imageWithColor(backgroundColor: UIColor) -> UIImage {
        let image = self
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        backgroundColor.setFill()
        //UIRectFill(CGRect(origin: .zero, size: image.size))
        let rect = CGRect(origin: .zero, size: image.size)
        let path = UIBezierPath(arcCenter: CGPoint(x:rect.midX, y:rect.midY), radius: rect.midX, startAngle: 0, endAngle: 6.28319, clockwise: true)
        path.fill()
        image.draw(at: .zero)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
#else
extension NSImage {
    
    /// Overlay an image with another image. The overlaying image will be centered and a quarter the size of the initial image.
    /// - Parameter overlay: The image to overlay
    /// - Returns: A new image, created as a merger of the initial image and the overlay.
    /// - Warning: If being used for a QR Code, the code's error correction must be as high as possible.
    func overlayWith(overlay: NSImage) -> NSImage {
        // Convert the images to CIImage
        guard let initialImage = CIImage(data: self.png!) else {
            print("Error: Could not convert initial image into CIImage in QRCodeDesigner.swift")
            return NSImage(imageLiteralResourceName: "codeFailure")
        }
        guard let overlayImage = CIImage(data: overlay.png!) else {
            print("Error: Could not convert overlay into CIImage in QRCodeDesigner.swift")
            return NSImage(imageLiteralResourceName: "codeFailure")
        }
        
        // Resize the
        guard let resizeFilter = CIFilter(name:"CILanczosScaleTransform") else {
            print("Error: Could not scale images in QRCodeDesigner.swift")
            return NSImage(imageLiteralResourceName: "codeFailure")
        }
        let scale = self.size.height * 0.25
        let aspectRatio = overlay.size.width / overlay.size.height
        
        resizeFilter.setValue(overlayImage, forKey: kCIInputImageKey)
        resizeFilter.setValue(scale, forKey: kCIInputScaleKey)
        resizeFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        let resizedOverlayImage = resizeFilter.outputImage
        
        guard let filter = CIFilter(name: "CIAdditionCompositing") else {
            print("Error: Could not composite images in QRCodeDesigner.swift")
            return NSImage(imageLiteralResourceName: "codeFailure")
        }
        filter.setDefaults()
        
        filter.setValue(resizedOverlayImage, forKey: "inputImage")
        filter.setValue(initialImage, forKey: "inputBackgroundImage")
        
        let combineResultImage = filter.outputImage
        
        let rep = NSCIImageRep(ciImage: combineResultImage!)
        let finalResult = NSImage(size: rep.size)
        finalResult.addRepresentation(rep)
        
        return finalResult
    }
}
#endif

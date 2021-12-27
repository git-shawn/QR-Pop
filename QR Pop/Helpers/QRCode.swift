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
import EFQRCode
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
    @Published var generatorSource: QRGeneratorType? = nil
    var overlayImage: Data? = nil {
        willSet {
            objectWillChange.send()
        }
        didSet {
            if overlayImage != nil {
                generate()
            }
        }
    }
    @Published var pointStyle: QRPointStyle = .square
    
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
        overlayImage = nil
        generate()
    }
    
    /// Generate a QR code.
    /// - Note: If the background color, foreground color, and data is not set in the QRCode object, an empty black and white code will be generated.
    /// - Warning: All codes are now generated using UTF8 encoding and cannot exceed 2000 characters of data.
    /// - Returns: PNG Data of a QR code.
    func generate() {
        var correctionLevel: EFInputCorrectionLevel
        
        switch errorLevel {
        // 7% error correction
        case 0:
            correctionLevel = .l
        // 15% error correction
        case 1:
            correctionLevel = .m
        // 25% error correction
        case 2:
            correctionLevel = .q
        // 30% error correction
        case 3:
            correctionLevel = .h
        default:
            correctionLevel = .m
        }
        
        let codeSize = EFIntSize(width: 1000, height: 1000)
        
        if (overlayImage == nil) {
            guard let cgCode = EFQRCode.generate(for: codeContent, encoding: .utf8, inputCorrectionLevel: correctionLevel, size: codeSize, backgroundColor: backgroundColor.cgColor!, foregroundColor: foregroundColor.cgColor!, pointStyle: pointStyle.efPointStyle) else { return imgData = errorImgData() }

            imgData = cgCode.png!
        } else {
            let scaleFactor = ((overlayImage?.image.size.width)!)/250
            let iconWidth = ((overlayImage?.image.size.width)!)/scaleFactor
            let iconHeight = ((overlayImage?.image.size.height)!)/scaleFactor
            let iconSize = EFIntSize(width: Int(iconWidth), height: Int(iconHeight))
            
            guard let cgCode = EFQRCode.generate(for: codeContent, encoding: .utf8, inputCorrectionLevel: .h, size: codeSize, backgroundColor: backgroundColor.cgColor!, foregroundColor: foregroundColor.cgColor!, icon: overlayImage?.cgImage!, iconSize: iconSize, pointStyle: pointStyle.efPointStyle) else { return imgData = errorImgData() }
            
            imgData = cgCode.png!
        }
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
        if (string.count > 2000) {
            print("Error: Content is too large to encode. QRCode.swift-166")
            codeContent = ""
        } else {
            codeContent = string
        }
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
        let error = NSImage(imageLiteralResourceName: "codeFailure").png!
        #else
        let error = UIImage(imageLiteralResourceName: "codeFailure").pngData()!
        #endif
        return error
    }
}

//MARK: - Image to Data Conversion Functions

extension CGImage {
    var png: Data? {
        guard let mutableData = CFDataCreateMutable(nil, 0),
            let destination = CGImageDestinationCreateWithData(mutableData, "public.png" as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(destination, self, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableData as Data
    }
}

#if os(macOS)
extension NSBitmapImageRep {
    var png: Data? { representation(using: .png, properties: [:]) }
}
extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
    var cgImage: CGImage? { self.image.cgImage(forProposedRect: nil, context: nil, hints: nil)}
}
extension NSImage {
    var png: Data? { tiffRepresentation?.bitmap?.png }
}
#else
extension Data {
    var cgImage: CGImage? { self.image.cgImage }
}
extension UIImage {
    var imageSizeInKB: Double { Double((pngData()!.count/1000)) }
}
#endif

//MARK: - Additional Point Styles

class StarPointStyle: EFPointStyle {
    func fillRect(context: CGContext, rect: CGRect, isStatic: Bool) {
        let path = CGMutablePath()
        var points: [CGPoint] = []
        let radius = Float(rect.width / 2)
        let angel = Double.pi * 2 / 5
        for i in 1...5 {
            let x = Float(rect.width / 2) - sinf(Float(i) * Float(angel)) * radius + Float(rect.origin.x)
            let y = Float(rect.height / 2) - cosf(Float(i) * Float(angel)) * radius + Float(rect.origin.y)
            points.append(CGPoint(x: CGFloat(x), y: CGFloat(y)))
        }
        path.move(to: points.first!)
        for i in 1...5 {
            let index = (2 * i) % 5
            path.addLine(to: points[index])
        }
        context.addPath(path)
        context.fillPath()
    }
}

enum QRPointStyle: Int, CaseIterable, Hashable {
    case square
    case circle
    case diamond
    case star

    var efPointStyle: EFPointStyle {
        switch self {
        case .square: return EFSquarePointStyle.square
        case .circle: return EFCirclePointStyle.circle
        case .diamond: return EFDiamondPointStyle.diamond
        case .star: return StarPointStyle()
        }
    }
}

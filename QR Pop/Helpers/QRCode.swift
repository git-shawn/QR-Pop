//
//  QRCode.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import Foundation
import SwiftUI
import Contacts
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class QRCode: NSObject {
    @AppStorage("errorCorrection") var errorLevel: Int = 0
    
    /// Generate a QR code from a String.
    /// - Parameters:
    ///   - content: String to encode into QR code.
    ///   - fg: Foreground color for the QR code.
    ///   - bg: Background color for the QR code.
    ///   - encoding: Optional, the method to encode the QR code into. ASCII for larger codes, UTF8 for more symbols.
    /// - Returns: PNG Data of a QR code.
    func generate(content: String, fg: Color, bg: Color, encoding: String.Encoding? = .ascii) -> Data {
        var stringToEncode = content
        
        // Too much data will cause the CIFilter to fail.
        if encoding == .ascii {
            if content.count > 4000 {
                print("Error, excessive data sent to QRCode.swift. ASCII encoded data should not exceed 4000 characters.")
                return errorImgData()
            } else {
                // Sanitize the string of any unencodable characters.
                stringToEncode = prepareStringForASCII(text: content)
            }
        } else {
            if content.count > 2000 {
                print("Error, excessive data sent to QRCode.swift. UTF8 encoded data should not exceed 2000 characters.")
                return errorImgData()
            }
        }
        
        // Create the CIFilter to make the QR code
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            print("Error initiating CIQRCodeGenerator CIFilter")
            return errorImgData()
        }

        // Encode the data
        guard let qrData = stringToEncode.data(using: encoding ?? .ascii) else {
            print("Error encoding content string. Invalid String likely passed to QRCode.generate().")
            return errorImgData()
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
            return errorImgData()
        }

        // Apply color to the QR Code
        colorFilter.setDefaults()
        colorFilter.setValue(qrFilter.outputImage, forKey: "inputImage")
        colorFilter.setValue(colorToCIColor(color: fg), forKey: "inputColor0")
        colorFilter.setValue(colorToCIColor(color: bg), forKey: "inputColor1")
        
        guard let ciImage = colorFilter.outputImage else {
            print("Error generating output image for QR code in QRCode.swift.")
            return errorImgData()
        }
        
        // Scale the QR code so that it looks nice on retina displays
        let transform = CGAffineTransform(scaleX: 25, y: 25)
        let scaledCIImage = ciImage.transformed(by: transform)
        
        // Convert the data to an NSImage
        let imgData = ciImgToData(image: scaledCIImage)
        
        return imgData
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
     func generateContact(contact: CNContact, bg: Color, fg: Color) -> Data {
         let vcard: String? = self.vcard(contact: contact)
         guard vcard != nil else {return errorImgData()}
         let code = self.generate(content: vcard!, fg: fg, bg: bg, encoding: .utf8)
         return code
     }
    
    /// Remove characters that cannot be encooded into ASCII
    /// - Parameter text: The string to remove special characters from.
    /// - Returns: Sanitized String.
    private func prepareStringForASCII(text: String) -> String {
        let allowedCharacters: Set<Character> = Set("%^*+=#}{][_\\|~<>.,?!-/:;()$&@1234567890qazwsxedcrfvtgbyhnujmikolp QAZWSXEDCRFVTGBYHNUJMIKOLP")
        return String(text.filter {allowedCharacters.contains($0)})
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

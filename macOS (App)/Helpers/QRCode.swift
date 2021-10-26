//
//  QRCode.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/22/21.
//

import Foundation
import SwiftUI
import Contacts

/// A helper class to generate QR codes.
class QRCode: NSObject {
    
    /// Options for Wifi Authentication Methods
    enum wifiAuthType {
        /// WEP Authentication
        case WEP
        /// WPA Authentication
        case WPA
    }
    
    @AppStorage("errorCorrection") var errorLevel: Int = 0
    
    /// Generate a QR code from a String.
    /// - Parameters:
    ///   - content: String to encode into QR code.
    ///   - fg: Foreground color for the QR code.
    ///   - bg: Background color for the QR code.
    ///   - encoding: Optional, the method to encode the QR code into. ASCII for larger codes, UTF8 for more symbols.
    /// - Returns: An NSImage of a QR code.
    func generate(content: String, fg: Color, bg: Color, encoding: String.Encoding? = .ascii) -> NSImage {
        var stringToEncode = content
        
        // Too much data will cause the CIFilter to fail.
        if encoding == .ascii {
            if content.count > 4000 {
                print("Error, excessive data sent to QRCode.swift. ASCII encoded data should not exceed 4000 characters.")
                return NSImage(imageLiteralResourceName: "codeFailure")
            } else {
                // Sanitize the string of any unencodable characters.
                stringToEncode = prepareStringForASCII(text: content)
            }
        } else {
            if content.count > 2000 {
                print("Error, excessive data sent to QRCode.swift. UTF8 encoded data should not exceed 2000 characters.")
                return NSImage(imageLiteralResourceName: "codeFailure")
            }
        }
        
        // Create the CIFilter to make the QR code
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            print("Error initiating CIQRCodeGenerator CIFilter")
            return NSImage(imageLiteralResourceName: "codeFailure")
        }

        // Encode the data
        guard let qrData = stringToEncode.data(using: String.Encoding.ascii) else {
            print("Error encoding content string. Invalid String likely passed to QRCode.generate().")
            return NSImage(imageLiteralResourceName: "codeFailure")
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
            return NSImage(imageLiteralResourceName: "codeFailure")
        }

        // Apply color to the QR Code
        colorFilter.setDefaults()
        colorFilter.setValue(qrFilter.outputImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(color: NSColor(fg)), forKey: "inputColor0")
        colorFilter.setValue(CIColor(color: NSColor(bg)), forKey: "inputColor1")
        
        guard let ciImage = colorFilter.outputImage else {
            print("Error generating output image for QR code in QRCode.swift.")
            return NSImage(imageLiteralResourceName: "codeFailure")
        }
        
        // Scale the QR code so that it looks nice on retina displays
        let transform = CGAffineTransform(scaleX: 25, y: 25)
        let scaledCIImage = ciImage.transformed(by: transform)
        
        // Convert the data to an NSImage
        let rep = NSCIImageRep(ciImage: scaledCIImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)

        return nsImage
    }
    
    /// Remove characters that cannot be encooded into ASCII
    /// - Parameter text: The string to remove special characters from.
    /// - Returns: Sanitized String.
    private func prepareStringForASCII(text: String) -> String {
        let allowedCharacters: Set<Character> = Set("%^*+=#}{][_\\|~<>.,?!-/:;()$&@1234567890qazwsxedcrfvtgbyhnujmikolp QAZWSXEDCRFVTGBYHNUJMIKOLP")
        return String(text.filter {allowedCharacters.contains($0)})
    }
    
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
    
    /// Generates a QR code for a given contact.
    /// - Parameters:
    ///   - contact: The CNContact to convert to a QR code.
    ///   - bg: The background color for the QR code.
    ///   - fg: The foregroound color for the QR code.
    ///   - correction: Optional, the error correction level for the QR code.
    /// - Returns: An image of  the QR code generated.
    func generateContact(contact: CNContact, bg: Color, fg: Color) -> NSImage {
        let vcard: String? = self.vcard(contact: contact)
        guard vcard != nil else {return NSImage(imageLiteralResourceName: "codeFailure")}
        let code = self.generate(content: vcard!, fg: fg, bg: bg, encoding: .utf8)
        return code
    }
    
    /// Generate a QR code to connect to a WiFi network.
    /// - Parameters:
    ///   - auth: The authentication method for the Wifi, either WEP or WPA.
    ///   - ssid: The network's SSID.
    ///   - password: The network's password.
    ///   - bg: The QR code's background color.
    ///   - fg: The QR code's foreground color.
    ///   - correction: Optional, the error correction level for the QR code.
    /// - Returns: An image of  the QR code generated.
    func generateWifi(auth: wifiAuthType, ssid: String, password: String, bg: Color, fg: Color) -> NSImage {
        var authType: String
        
        switch auth {
            case .WEP:
                authType = "WEP"
            case .WPA:
                authType = "WPA"
        }
        
        let dataString = "WIFI:T:\(authType);S:\(ssid);P:\(password);;"
        let code = self.generate(content: dataString, fg: fg, bg: bg)
        return code
    }
}

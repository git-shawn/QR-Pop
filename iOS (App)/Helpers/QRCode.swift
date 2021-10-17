//
//  QRCode.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/17/21.
//

import Foundation
import Contacts
import EventKit
import SwiftUI

/// A helper class to facilitate the generation of QR codes.
final class QRCode {
    
    /// Correction levels for a QR Code
    enum correctionLevel {
        /// Correct up to 7% of damage
        case L
        /// Correct up to 15% of damage
        case M
        /// Correct up to 25% of damage
        case Q
        /// Correct up to 30% of damage
        case H
    }
    
    /// Options for Wifi Authentication Methods
    enum wifiAuthType {
        /// WEP Authentication
        case WEP
        /// WPA Authentication
        case WPA
    }
    
    /// This function generates a QR code from a String.
    /// - Parameters:
    ///   - content: The String to encode as a QR code.
    ///   - bg: The background color for the QR code.
    ///   - fg: The foreground color for the QR code.
    ///   - correction: Optional, the error correction level for the QR code.
    /// - Returns: PNG Data representing the QR code generated.
    func generate(content: String, bg: Color, fg: Color, correction: correctionLevel? = correctionLevel.L) -> Data? {
        //Create CoreImage filters for the qr code
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
    
        //Convert text input to data
        let data = content.data(using: .ascii, allowLossyConversion: false)
        
        filter.setValue(data, forKey: "inputMessage")
        switch correction {
            case .L:
                filter.setValue("L", forKey: "inputCorrectionLevel")
            case .M:
                filter.setValue("M", forKey: "inputCorrectionLevel")
            case .Q:
                filter.setValue("Q", forKey: "inputCorrectionLevel")
            case .H:
                filter.setValue("H", forKey: "inputCorrectionLevel")
            case .none:
                filter.setValue("L", forKey: "inputCorrectionLevel")
        }
        colorFilter.setValue(filter.outputImage, forKey: "inputImage")
        
        //Set the background color
        colorFilter.setValue(CIColor(color: UIColor(bg)), forKey: "inputColor1")
        
        //Set the foreground color
        colorFilter.setValue(CIColor(color: UIColor(fg)), forKey: "inputColor0")
        
        //Apply the colors
        guard let ciimage = colorFilter.outputImage else { return nil }
        
        //Increase the code's image size
        let transform = CGAffineTransform(scaleX: 15, y: 15)
        let scaledCIImage = ciimage.transformed(by: transform)
        
        //Convert CoreImage to UIImage
        let uiimage = UIImage(ciImage: scaledCIImage)
        return uiimage.pngData()!
    }
   
    
    /// Generate a vCard from a Contact.
    /// - Parameter contact: The contact to transform into a vCard.
    /// - Returns: The vCard data as a String. If error, returns nil.
    private func vcard(contact: CNContact) -> String? {
        var data = Data()
        
        do {
            try (data = CNContactVCardSerialization.data(with: [contact]))
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
    /// - Returns: PNG Data representing the QR code generated.
    func generateContact(contact: CNContact, bg: Color, fg: Color, correction: correctionLevel? = .L) -> Data? {
        let vcard: String? = self.vcard(contact: contact)
        guard vcard != nil else {return nil}
        let code = self.generate(content: vcard!, bg: bg, fg: fg, correction: correction)
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
    /// - Returns: PNG Data representing the QR code generated.
    func generateWifi(auth: wifiAuthType, ssid: String, password: String, bg: Color, fg: Color, correction: correctionLevel? = .L) -> Data? {
        var authType: String
        
        switch auth {
            case .WEP:
                authType = "WEP"
            case .WPA:
                authType = "WPA"
        }
        
        let dataString = "WIFI:T:\(authType);S:\(ssid);P:\(password);;"
        let code = self.generate(content: dataString, bg: bg, fg: fg, correction: correction)
        return code
    }
    
    
    /// Generate a QR code representing a calendar event. Accepts event parameters.
    /// - Parameters:
    ///   - title: The title of the event.
    ///   - start: The start Date() of the event.
    ///   - end: The end Date() of the event.
    ///   - description: Optional, a description of the event.
    ///   - location: Optional, a location for the event.
    ///   - bg: The background color for the event.
    ///   - fg: The foreground color for the event.
    ///   - correction: Optional, the error correction level for the QR code.
    /// - Returns: PNG Data representing the QR code generated.
    func generateEvent(title: String, start: Date, end: Date, description: String? = nil, location: String? = nil, bg: Color, fg: Color, correction: correctionLevel? = .L) -> Data? {
        var dataString: String
        
        // Format the date so that the calendar can read it
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd'T'HH:mm:ss.SSSZZZZZ"
        
        // Convert DATE() Objects to String
        let startStr = formatter.string(from: start)
        let endStr = formatter.string(from: end)
        
        if (description != nil && location == nil) {
            dataString = "BEGIN:VEVENT\nSUMMARY:\(title)\nDESCRIPTION:\(description!)\nDTSTART:\(startStr)\nDTEND:\(endStr)\nEND:VEVENT"
        } else if (description == nil && location != nil) {
            dataString = "BEGIN:VEVENT\nSUMMARY:\(title)\nLOCATION:\(location!)\nDTSTART:\(startStr)\nDTEND:\(endStr)\nEND:VEVENT"
        } else {
            dataString = "BEGIN:VEVENT\nSUMMARY:\(title)\nDESCRIPTION:\(description!)\nLOCATION:\(location!)\nDTSTART:\(startStr)\nDTEND:\(endStr)\nEND:VEVENT"
        }
        let code = self.generate(content: dataString, bg: bg, fg: fg, correction: correction)
        return code
    }
    
    /// Generate a QR code representing a calendar event. Accepts a calendar event.
    /// - Parameters:
    ///   - event: The calendar event to encode into a QR code.
    ///   - bg: The background color for the event.
    ///   - fg: The foreground color for the event.
    ///   - correction: Optional, the error correction level for the QR code.
    /// - Returns: PNG Data representing the QR code generated.
    func generateEventFromCalendar(event: EKEvent, bg: Color, fg: Color, correction: correctionLevel? = .L) -> Data? {
        let start: Date = event.startDate
        let end: Date = event.endDate
        let location: String = event.location ?? ""
        let title: String = event.title
        let description: String = event.description
        
        let code = generateEvent(title: title, start: start, end: end, description: description, location: location, bg: bg, fg: fg, correction: correction)
        return code
    }
}
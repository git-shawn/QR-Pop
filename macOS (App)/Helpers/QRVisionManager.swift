//
//  QRVisionManager.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/26/21.
//

import Foundation
import Contacts
import CoreWLAN

class QRVisionManager: NSObject {
    static let shared = QRVisionManager()

    private override init() {
        super.init()
    }
    
    var visionResult: String = ""
    
    enum visionResponse {
        case noCameraAccess
        case noCamera
        case noCodeFound
        case codeFound
        case error
    }
    
    func interpretResult(string: String) {
        visionResult = string
        
        if visionResult.isValidURL {
            
        }
    }
    
    /// Determines if a string is a Contact
    ///
    /// This shoould be used in conjunction with convertVCardtoCNContact() to recieve an actual CNContact. Example:
    /// ````
    /// if isContact(string: String) {
    ///     contact = convertVCardtoCNContact(string: String)
    /// }
    /// ````
    /// - Parameter string: The string to examine
    /// - Returns: True if a contact, false if not
    private func isContact(string: String) -> Bool {
        if string.contains("VCARD") {
            return true
        }
        return false
    }
    
    /// Converts a vCard string to a CNContact
    /// - Parameter string: A string representing a vCard
    /// - Returns: A CNContact of the vCard
    /// - Warning: Ensure that the String being passed represents a vCard first, otherwise you'll recieve nil.
    private func convertVCardToCNContact(string: String) -> CNContact? {
        guard let vcardData = string.data(using: string.fastestEncoding) else {return nil}
        var contact: [CNContact]
        do {
            try contact = CNContactVCardSerialization.contacts(with: vcardData)
            return contact[0]
        } catch {
            print("Error converting contact: \(error)")
        }
        return nil
    }
    
    private func connectWifi(ssid: String, pass: String, isWEP: Bool) {
        do {
            let networks = try CWWiFiClient.shared().interface()?.scanForNetworks(withName: ssid)
            let network = networks?.first
            do {
                try CWWiFiClient.shared().interface()?.associate(to: network!, password: pass)
            } catch {
                print("Unable to connect to network \(ssid)")
            }
        } catch {
            print("Unable to find network: \(error)")
        }
    }
}

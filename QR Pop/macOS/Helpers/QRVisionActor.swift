//
//  QRVisionActor.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 11/15/21.
//

import Foundation
import AppKit
import Contacts
import SwiftUI
import ContactsUI
import EventKit
import CoreWLAN

class QRVisionActor {
    
    /// The type of data found encoded in a QR code that QR Pop can act upon.
    enum QRCodeDataType {
        case url
        case contact
        case event
        case location
        case network
        case plaintext
        case unknown
    }
    
    /// Determines the type of data within a given payload.
    /// - Parameter payload: A payload returned from QRVisionView.
    /// - Returns: The type of data represented by a payload.
    func interpret(payload: String?) -> QRCodeDataType {
        if payload != nil {
            if payload!.isValidURL || payload!.contains("facetime:") || payload!.contains("facetime-audio:") || payload!.contains("shortcuts://") {
                return .url
            } else if payload!.contains("BEGIN:VCARD") {
                return .contact
            } else if payload!.contains("BEGIN:VEVENT") {
                return .event
            } else if payload!.contains("geo:"){
                return .location
            } else if payload!.contains("WIFI:"){
                return .network
            } else if payload!.isEmpty {
                return .unknown
            } else if payload!.contains("mailto:"){
                return .url
            } else {
                return .plaintext
            }
        } else {
            print("The payload was not a valid String")
            return .unknown
        }
    }
    
    /// Handles a QRVision payload based on type.
    /// - Parameters:
    ///   - payload: A payload returned from QRVisionView
    ///   - type: The type as identified by `QRVisionActor.interpret`
    /// - Precondition: You must determine the type using `QRVisionActor.interpret` first.
    func handle(payload: String, type: QRCodeDataType) {
        switch type {
        case .url:
            urlHandler(payload: payload)
        case .contact:
            vcardHandler(payload: payload)
        case .event:
            eventHandler(payload: payload)
        case .location:
            geoHandler(payload: payload)
        case .network:
            networkHandler(payload: payload)
        case .plaintext:
            textHandler(payload: payload)
        case .unknown:
            DispatchQueue.main.async {
                let alert = NSAlert.init()
                alert.messageText = "Scanner Error"
                alert.informativeText = "QR Pop was unable to interpret that QR Code"
                alert.runModal()
            }
        }
    }

// -MARK: The below functions perform actions depending on the type of payload found in the QR Code.
    
    /// Opens a URL discovered in a payload. This function can open the following types:
    /// - Web addresses (http, https)
    /// - `mailto:` addresses
    /// - `tel:` addresses
    /// - `facetime:` addresses
    /// - `sms:` addresses
    /// - `shortcuts:` addresses
    /// - Parameter payload: A payload returned from QRVisionView.
    /// - Warning: This function will automatically open the URL. Do not call until the user has consented.
    private func urlHandler(payload: String) {
        // Converting the payload into Data allows NSWorkspace to accept URLs with Emojis.
        // This is important for Shortcuts, E-Mail, or other Deep Links which may include Emojis.
        NSWorkspace.shared.open(URL(dataRepresentation: payload.data(using: .utf8)!, relativeTo: nil)!)
    }
    
    /// Creates a contact from a vCard discovered in a payload.
    /// The system will present the contact to the user and ask for consent before adding it to their address book, so this function can be safely called whenever.
    /// - Parameter payload: A payload returned from QRVisionView.
    private func vcardHandler(payload: String) {
        var contact: CNContact
        do {
            try contact = CNContactVCardSerialization.contacts(with: payload.data(using: .utf8)!).first!
        } catch {
            print("Error serializing vCard in QRVisionActor.swift")
            DispatchQueue.main.async {
                let alert = NSAlert.init()
                alert.messageText = "Unable to Read Contact"
                alert.informativeText = "QR Pop was unable to interpret that QR Code"
                alert.runModal()
            }
            return
        }
        let vc = CNContactViewController()
        vc.contact = contact
        vc.title = "Scanned Contact"
        NSApplication.shared.windows.first?.contentViewController?.present(vc, asPopoverRelativeTo: .zero, of: NSApplication.shared.windows.first!.contentViewController!.view, preferredEdge: .maxY, behavior: .transient)
    }
    
    /// Creates a calendar event from data discovered in a payload.
    /// The system will present the event to the user and ask for consent before adding it to their calendar, so this function can be safely called whenever.
    /// - Parameter payload: A payload returned from QRVisionView.
    private func eventHandler(payload: String) {
        // -TODO: Handle event payloads.
    }
    
    /// Opens `geo://` addresses discovered in a payload in Apple Maps.
    /// - Parameter payload: A payload returned from QRVisionView.
    /// - Warning: This function will automatically open the location. Do not call until the user has consented.
    private func geoHandler(payload: String) {
        // Delete `geo:`, the first four letters of the payload.
        let payloadPath = payload.dropFirst(4)
        NSWorkspace.shared.open(URL(string: "http://maps.apple.com/?ll=\(String(payloadPath))")!)
    }
    
    /// Attempt to connect the device to a network discovered in a payload.
    /// - Parameter payload: A payload returned from QRVIsionView.
    /// - Warning: This function will automatically connect to a network. Do not call until the user has consented.
    private func networkHandler(payload: String) {
        var isWEP: Bool? = nil //This may not be necessary for macOS
        var ssid: String = ""
        var pass: String = ""
        
        // Remove WIFI: from the beginning
        let parameterString = String(payload[(payload.index(payload.startIndex, offsetBy: 5))...])
        let parameters = parameterString.split(separator: ";")
        parameters.forEach {parameter in
            if parameter.contains("T") {
                if parameter.contains("WEP") {
                    isWEP = true
                } else {
                    isWEP = false
                }
            } else if parameter.contains("S") {
                let ssidParam = String(parameter).split(separator: ":")
                ssid = String(ssidParam.last!)
            } else if parameter.contains("P") {
                let passParam = String(parameter).split(separator: ":")
                pass = String(passParam.last!)
            }
        }
        if isWEP != nil {
            let wifiInterface = CWWiFiClient.shared().interface()
            do {
                // Scan for a network with the same SSID name as provided.
                let wifiNetworks = try wifiInterface?.scanForNetworks(withName: ssid)
                // The above function returns an optional set, but we only need the first one.
                guard let wifiNetwork = wifiNetworks?.first else {
                    // If no network is found in the set, alert the user.
                    DispatchQueue.main.async {
                        let alert = NSAlert.init()
                        alert.messageText = "No Network Found"
                        alert.informativeText = "QR Pop was unable to find the network named \"\(ssid)\"."
                        alert.runModal()
                    }
                    return
                }
                do {
                    // If a network is found in the set, attempt to associate with it.
                    try wifiInterface?.associate(to: wifiNetwork, password: pass)
                    // Alert the user of a successful association.
                    DispatchQueue.main.async {
                        let alert = NSAlert.init()
                        alert.messageText = "Connected"
                        alert.informativeText = "QR Pop connected you to the network named \"\(ssid)\"."
                        alert.runModal()
                    }
                } catch {
                    // If the association fails, warn the user.
                    DispatchQueue.main.async {
                        let alert = NSAlert.init()
                        alert.messageText = "Could Not Connect"
                        alert.informativeText = "QR Pop was unable to connect to the network named \"\(ssid)\". Make sure the password encoded in the QR code you scanned is correct, then try again."
                        alert.runModal()
                    }
                }
            } catch {
                // If interfacing fails, warn the user.
                DispatchQueue.main.async {
                    let alert = NSAlert.init()
                    alert.messageText = "No Network Found"
                    alert.informativeText = "QR Pop was unable to find the network named \"\(ssid)\"."
                    alert.runModal()
                }
            }
        }
    }
    
    /// Copy plain text found in a payload to the clipboarad.
    /// - Parameter payload: A payload returned from QRVIsionView.
    private func textHandler(payload: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setData(payload.data(using: .utf8), forType: NSPasteboard.PasteboardType.string)
    }
}

private struct ContactViewController: NSViewControllerRepresentable {
    var contact: CNContact
    
    func makeNSViewController(context: Context) -> CNContactViewController {
        let vc = CNContactViewController()
        vc.contact = contact
        vc.title = "Scanned Contact"
        return vc
    }
    
    func updateNSViewController(_ nsViewController: CNContactViewController, context: Context) {
        //nothing!
    }
    
    typealias NSViewControllerType = CNContactViewController
}

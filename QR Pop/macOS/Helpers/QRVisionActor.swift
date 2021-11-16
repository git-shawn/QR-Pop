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
        NSWorkspace.shared.open(URL(string: payload)!)
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
        NSApplication.shared.windows.first?.contentViewController?.presentAsModalWindow(vc)
    }
    
    /// Creates a calendar event from data discovered in a payload.
    /// The system will present the event to the user and ask for consent before adding it to their calendar, so this function can be safely called whenever.
    /// - Parameter payload: A payload returned from QRVisionView.
    private func eventHandler(payload: String) {
        #warning("Calendar Event Payloads are Unhandled")
        let eventStore: EKEventStore = EKEventStore()
        eventStore.requestAccess(to: .event, completion: { granted, error in
            if (granted && error == nil) {
                let event: EKEvent = EKEvent(eventStore: eventStore)
            }
        })
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
        #warning("Network Payloads are Unhandled")
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
        return vc
    }
    
    func updateNSViewController(_ nsViewController: CNContactViewController, context: Context) {
        //nothing!
    }
    
    typealias NSViewControllerType = CNContactViewController
}

//
//  QRGeneratorStore.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import Foundation
import SwiftUI

struct QRGeneratorType: Identifiable {
    var id: Int
    let name: String
    let description: String
    let icon: String
    let destination: AnyView
}

let QRViews: [QRGeneratorType] = [
    QRGeneratorType.init(id: 1, name: "Link", description: "Opens a webpage when scanned.", icon: "link", destination: AnyView(QRLinkView())),
    QRGeneratorType.init(id: 2, name: "Wifi Network", description: "Connects a device to a wifi network when scanned.", icon: "wifi", destination: AnyView(QRWifiView())),
    QRGeneratorType.init(id: 3, name: "Calendar Event", description: "Adds a calendar event when scanned.", icon: "calendar", destination: AnyView(QRCalendarView())),
    QRGeneratorType.init(id: 4, name: "Contact Card", description: "Adds a contact when scanned.", icon: "person.crop.square.filled.and.at.rectangle", destination: AnyView(QRContactView())),
    QRGeneratorType.init(id: 5, name: "Email", description: "Sends an email when scanned.", icon: "envelope", destination: AnyView(QRMailView())),
    QRGeneratorType.init(id: 6, name: "Phone Number", description: "Begins a call when scanned.", icon: "phone", destination: AnyView(QRPhoneView())),
    QRGeneratorType.init(id: 7, name: "Text Message", description: "Initiates a text message when scanned.", icon: "text.bubble", destination: AnyView(QRSMSView())),
    QRGeneratorType.init(id: 8, name: "FaceTime", description: "Begins a FaceTime call when scanned.", icon: "video", destination: AnyView(QRFacetimeView())),
    QRGeneratorType.init(id: 9, name: "Twitter", description: "Opens Twitter when scanned.", icon: "at", destination: AnyView(QRTwitterView())),
    QRGeneratorType.init(id: 10, name: "Location", description: "Opens Maps to a specified location when scanned.", icon: "map", destination: AnyView(QRLocationView())),
    QRGeneratorType.init(id: 11, name: "Plain Text", description: "Presents some text when scanned.", icon: "doc.text", destination: AnyView(QRTextView())),
    QRGeneratorType.init(id: 12, name: "Shortcuts", description: "Activates a Shortcut when scanned.", icon: "square.2.stack.3d", destination: AnyView(QRShortcutView())),
    QRGeneratorType.init(id: 13, name: "Bitcoin", description: "Requests a specified cryptocurrency when scanned.", icon: "bitcoinsign.circle", destination: AnyView(QRCryptoView()))
]

//
//  QRGeneratorStore.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import Foundation
import SwiftUI

struct QRGeneratorType: Identifiable {
    let name: String
    let description: String
    let icon: String
    let destination: AnyView
    var id: String { name }
}

let QRViews: [QRGeneratorType] = [
    QRGeneratorType.init(name: "Link", description: "Opens a webpage when scanned.", icon: "link", destination: AnyView(QRLinkView())),
    QRGeneratorType.init(name: "Wifi Network", description: "Connects a device to a wifi network when scanned.", icon: "wifi", destination: AnyView(QRWifiView())),
    QRGeneratorType.init(name: "Calendar Event", description: "Adds a calendar event when scanned.", icon: "calendar", destination: AnyView(QRCalendarView())),
    QRGeneratorType.init(name: "Contact Card", description: "Adds a contact when scanned.", icon: "person.crop.square.filled.and.at.rectangle", destination: AnyView(QRContactView())),
    QRGeneratorType.init(name: "Email", description: "Sends an email when scanned.", icon: "envelope", destination: AnyView(QRMailView())),
    QRGeneratorType.init(name: "Phone Number", description: "Begins a call when scanned.", icon: "phone", destination: AnyView(QRPhoneView())),
    QRGeneratorType.init(name: "Text Message", description: "Initiates a text message when scanned.", icon: "text.bubble", destination: AnyView(QRSMSView())),
    QRGeneratorType.init(name: "FaceTime", description: "Begins a FaceTime call when scanned.", icon: "video", destination: AnyView(QRFacetimeView())),
    QRGeneratorType.init(name: "Twitter", description: "Opens Twitter when scanned.", icon: "at", destination: AnyView(QRTwitterView())),
    QRGeneratorType.init(name: "Location", description: "Opens Maps to a specified location when scanned.", icon: "map", destination: AnyView(QRLocationView())),
    QRGeneratorType.init(name: "Plain Text", description: "Presents some text when scanned.", icon: "doc.text", destination: AnyView(QRTextView())),
    QRGeneratorType.init(name: "Shortcuts", description: "Activates a Shortcut when scanned.", icon: "square.2.stack.3d", destination: AnyView(QRShortcutView())),
    QRGeneratorType.init(name: "Bitcoin", description: "Requests a specified cryptocurrency when scanned.", icon: "bitcoinsign.circle", destination: AnyView(QRCryptoView()))
]

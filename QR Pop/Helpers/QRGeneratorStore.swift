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
    let icon: String
    let destination: AnyView
    var id: String { name }
}

let QRViews: [QRGeneratorType] = [
    QRGeneratorType.init(name: "Link", icon: "link", destination: AnyView(QRLinkView())),
    QRGeneratorType.init(name: "Wifi Network", icon: "wifi", destination: AnyView(QRWifiView())),
    QRGeneratorType.init(name: "Calendar Event", icon: "calendar", destination: AnyView(QRCalendarView())),
    QRGeneratorType.init(name: "Contact Card", icon: "person.crop.square.filled.and.at.rectangle", destination: AnyView(QRContactView())),
    QRGeneratorType.init(name: "Email", icon: "envelope", destination: AnyView(QRMailView())),
    QRGeneratorType.init(name: "Phone Number", icon: "phone", destination: AnyView(QRPhoneView())),
    QRGeneratorType.init(name: "Text Message", icon: "text.bubble", destination: AnyView(QRSMSView())),
    QRGeneratorType.init(name: "FaceTime", icon: "video", destination: AnyView(QRFacetimeView())),
    QRGeneratorType.init(name: "Twitter", icon: "at", destination: AnyView(QRTwitterView())),
    QRGeneratorType.init(name: "Location", icon: "map", destination: AnyView(QRLocationView())),
    QRGeneratorType.init(name: "Plain Text", icon: "doc.text", destination: AnyView(QRTextView())),
    QRGeneratorType.init(name: "Shortcuts", icon: "square.2.stack.3d", destination: AnyView(QRShortcutView()))
]

//
//  BuilderContentModel.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/10/23.
//

import SwiftUI

/// Accepts and interprets data submitted to BuilderView.
struct BuilderModel: Hashable, Equatable {
    var responses: [String]
    var result: String
    var builder: Kind
}

//MARK: - Init

extension BuilderModel {
    
    init() {
        self.init(
            responses: [],
            result: "",
            builder: .link)
    }
    
    /// Created a Builder Model with empty responses, no result, and of a predefined ``Kind``.
    /// - Parameter kind: The ``Kind`` of Builder to be used.
    init(for kind: Kind) {
        self.init(
            responses: [],
            result: "",
            builder: kind)
    }
    
    init(text: String) {
        self.responses = [text]
        self.result = text
        self.builder = .text
    }
}

//MARK: - Functions

extension BuilderModel {
    
    /// Erase all data within the model excluding the ``builder`` property.
    mutating func resetData() {
        self.responses = []
        self.result = ""
    }
}

//MARK: - Builder Categories

extension BuilderModel {
    enum Kind: String, Hashable, CaseIterable, Codable, Equatable {
        case link, wifi, event, contact, email, phone, sms, whatsapp, facetime, twitter, location, text, shortcut
        
        var title: String {
            switch self {
            case .link:
                return "Link"
            case .wifi:
                return "Wifi Network"
            case .event:
                return "Calendar Event"
            case .email:
                return "Email"
            case .phone:
                return "Phone Number"
            case .sms:
                return "Text Message"
            case .facetime:
                return "FaceTime"
            case .twitter:
                return "X.com"
            case .shortcut:
                return "Shortcut"
            case .location:
                return "Location"
            case .text:
                return "Plain Text"
            case .contact:
                return "Contact Card"
            case .whatsapp:
                return "WhatsApp"
            }
        }
        
        var icon: Image {
            switch self {
            case .link:
                return Image(systemName: "link")
            case .wifi:
                return Image(systemName: "wifi")
            case .event:
                return Image(systemName: "calendar")
            case .contact:
                return Image(systemName: "person.crop.square.filled.and.at.rectangle")
            case .email:
                return Image(systemName: "envelope")
            case .phone:
                return Image(systemName: "phone")
            case .sms:
                return Image(systemName: "text.bubble")
            case .facetime:
                return Image(systemName: "video")
            case .twitter:
                return Image("xLogo")
            case .location:
                return Image(systemName: "location.viewfinder")
            case .text:
                return Image(systemName: "doc.text")
            case .shortcut:
                return Image(systemName: "square.2.layers.3d")
            case .whatsapp:
                return Image("whatsapp.fill")
            }
        }
        
#if !EXTENSION && !CLOUDEXT
        @ViewBuilder
        func getView(model: Binding<BuilderModel>) -> some View {
            switch self {
            case .link:
                LinkForm(model: model)
            case .wifi:
                WifiForm(model: model)
            case .event:
                EventForm(model: model)
            case .contact:
                ContactForm(model: model)
            case .email:
                MailForm(model: model)
            case .phone:
                PhoneForm(model: model)
            case .sms:
                SMSForm(model: model)
            case .facetime:
                FacetimeForm(model: model)
            case .twitter:
                TwitterForm(model: model)
            case .location:
                MapForm(model: model)
            case .text:
                TextForm(model: model)
            case .shortcut:
                ShortcutForm(model: model)
            case .whatsapp:
                WhatsAppForm(model: model)
            }
        }
#endif
    }
}

//MARK: - Codable

extension BuilderModel: Codable {
    
    /// Converts this `BuilderModel` to `JSON` data.
    /// - Returns: `JSON` data.
    func asData() throws -> Data {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return data
    }
}

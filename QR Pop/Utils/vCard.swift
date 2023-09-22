//
//  SanitizeVCard.swift
//  QR Pop
//
//  Created by Shawn Davis on 8/28/23.
//

import Contacts
import Connections

class vCard {
    
    /// Convert a `CNContact` into a `String` representation of a vCard without unecessary data like images.
    /// - Parameter contact: The `CNContact` to serialize.
    /// - Returns: A sanitized `String` representation
    static func sanitarySerialization(of contact: CNContact) throws -> String {
        let vdata = try CNContactVCardSerialization.data(with: [contact])
        let vstring = String(decoding: vdata, as: UTF8.self)
        return sanitize(vstring)
    }
    
    /// Convert a `CNMutableContact` into a `String` representation of a vCard without unecessary data like images.
    /// - Parameter contact: The `CNMutableContact` to serialize.
    /// - Returns: A sanitized `String` representation
    static func sanitarySerialization(of mutableContact: CNMutableContact) throws -> String {
        let vdata = try CNContactVCardSerialization.data(with: [mutableContact])
        let vstring = String(decoding: vdata, as: UTF8.self)
        return sanitize(vstring)
    }
    
    /// Strips excess data from a known vCard String that would be unsuitable for a QR code such as images.
    /// Device information is also removed.
    /// - Parameter vcard: A `String` representing a vCard.
    /// - Returns: A sanitized `String`.
    static func sanitize(_ vcard: String) -> String {
        var vcardProps = vcard.split(whereSeparator: \.isNewline)
        vcardProps.removeAll(where: { $0.starts(with: "PHOTO") })
        vcardProps.removeAll(where: { $0.starts(with: "LOGO") })
        vcardProps.removeAll(where: { $0.starts(with: "PRODID") })
        return vcardProps.joined(separator: "\n")
    }
}

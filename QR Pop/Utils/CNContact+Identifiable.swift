//
//  CNContact+Identifiable.swift
//  QR Pop
//
//  Created by Shawn Davis on 7/17/23.
//

import Foundation
import Contacts

extension CNContact: Identifiable {
    public var id: UUID {
        UUID()
    }
}

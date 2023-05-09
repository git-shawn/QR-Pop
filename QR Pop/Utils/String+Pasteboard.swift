//
//  String+Pasteboard.swift
//  QR Pop
//
//  Created by Shawn Davis on 5/9/23.
//

import Foundation
import UniformTypeIdentifiers
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension String {
    
    /// Adds this string to the general pasteboard.
    func addToPasteboard() {
#if canImport(UIKit)
        UIPasteboard.general.setValue(self, forPasteboardType: UTType.plainText.identifier)
#elseif canImport(AppKit)
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(self, forType: .string)
#endif
    }
}

//
//  Clipboard.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/23/21.
//

import Foundation
import Cocoa

class Clipboard {
    
    /// Get a URL from the Pasteboard if it is the first object (most recently copied).
    /// - Returns: The URL in the pasteboard, as a String. If none, returns nil.
    /// - Warning: This function is highly likely to return nil.
    static func getFirstURL() -> String? {
        let pbItem = NSPasteboard.general.pasteboardItems?.first?.string(forType: .string)
        if (pbItem != nil) {
            if pbItem!.isValidURL {
                return pbItem!
            }
        }
        return nil
    }
    
    /// Adds an image to the Pasteboard as a PNG
    /// - Parameter image: Image to write
    static func writeImage(image: NSImage) {
        let imageData = image.png
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setData(imageData, forType: NSPasteboard.PasteboardType.png)
    }
}

extension String {
    
    /// True if a String is a valid URL, false if not.
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}

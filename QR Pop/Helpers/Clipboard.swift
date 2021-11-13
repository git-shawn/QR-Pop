//
//  Clipboard.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class Clipboard {
    
    /// Get a URL from the Pasteboard if it is the first object (most recently copied).
    /// - Returns: The URL in the pasteboard, as a String. If none, returns nil.
    /// - Warning: This function is highly likely to return nil.
    static func getFirstURL() -> String? {
        #if os(macOS)
        let pbItem = NSPasteboard.general.pasteboardItems?.first?.string(forType: .string)
        if (pbItem != nil) {
            if pbItem!.isValidURL {
                return pbItem!
            }
        }
        #else
        if (UIPasteboard.general.hasURLs) {
            return UIPasteboard.general.url?.absoluteString
        }
        #endif
        return nil
    }
    
    /// Adds an image to the Pasteboard as a PNG
    /// - Parameter image: Image to write
    static func writeImage(imageData: Data) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setData(imageData, forType: NSPasteboard.PasteboardType.png)
        #else
        UIPasteboard.general.image = UIImage(data: imageData)
        #endif
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

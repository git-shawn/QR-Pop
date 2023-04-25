//
//  String+QRPop.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/10/23.
//

import Foundation

extension String {
    
    /// This string with the first letter uppercased.
    var uppercaseFirstLetter: String { prefix(1).uppercased() + dropFirst() }
    
    /// Returns this `String` with a specified `String` prefix removed.
    /// - Parameter prefix: The prefix to remove.
    /// - Returns: This string, sans the prefix.
    func removePrefix(_ prefix: String) -> String {
        if self.hasPrefix(prefix) {
            return String(self.dropFirst(prefix.count))
        } else {
            return self
        }
    }
    
    /// Returns true if the entire String is a valid URL.
    ///
    /// - Warning: *Valid* is a relative term here. While the URL may be formatted correctly, there are no guarantees that the resource it points to is actually available.
    public var isURL: Bool {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return false }
        if let match = detector.firstMatch(in: self, range: NSRange(location: 0, length: self.utf16.count)) {
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}

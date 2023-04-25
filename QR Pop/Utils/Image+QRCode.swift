//
//  Image+QRCode.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/23/23.
//

import QRCode

extension PlatformImage {
    
    /// A `Boolean` indicating whether or not this particular image contains a QR code.
    var containsQRCode: Bool {
        guard let detection = QRCode.DetectQRCodes(in: self) else {
            return false
        }
        
        return !detection.isEmpty
    }
}

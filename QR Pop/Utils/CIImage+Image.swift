//
//  CIImage+Image.swift
//  QR Pop
//
//  Created by Shawn Davis on 5/3/23.
//

import SwiftUI

extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent)
        else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

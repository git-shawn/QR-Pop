//
//  Color+QRCode.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI
import QRCode
import OSLog

extension Color {
    
    /// A `QRCode.FillStyle.Solid` object instantiated with the current color.
    /// - Warning: Returns black on failure
    var fillStyleGenerator: QRCodeFillStyleGenerator {
        if let cgColor = cgColor {
            return QRCode.FillStyle.Solid(cgColor)
        } else {
            Logger.logModel.error("Color: Color does not have member CGColor.")
            return QRCode.FillStyle.Solid(.black)
        }
    }
    
    /// A `QRCode.FillStyle.Solid` object instantiated with the current color at the specified opacity.
    /// - Parameter withAlpha: An opacity level, between `0.0 – 1.0`, to use.
    /// - Returns: A `QRCodeFillStyleGenerator`.
    /// - Warning: Returns black on failure
    func fillStyleGenerator(withAlpha: Double) -> QRCodeFillStyleGenerator {
        let color = self.opacity(withAlpha)
        
        if let cgColor = color.cgColor {
            return QRCode.FillStyle.Solid(cgColor)
        } else {
            Logger.logModel.error("Color: Color does not have member CGColor.")
            return QRCode.FillStyle.Solid(.black)
        }
    }
}

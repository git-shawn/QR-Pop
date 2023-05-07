//
//  Color+QRPop.swift
//  QR Pop Watch App
//
//  Created by Shawn Davis on 5/7/23.
//

import SwiftUI

extension Color {
    
    /// A Boolean value indicating whether or not this particular color is "dark."
    /// - Credit: - [https://stackoverflow.com/a/75716714/20422552](https://stackoverflow.com/a/75716714/20422552)
    var isDark: Bool {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
        guard UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: nil) else {
            return false
        }
        
        let lum = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return lum < 0.5
    }
}

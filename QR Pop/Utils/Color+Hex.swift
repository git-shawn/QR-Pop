//
//  Color+Hex.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/27/23.
//

import SwiftUI

extension Color {
    
    /// Creates a color from a hexadecimal value as a `String`.
    /// This function can be called with hex values 3, 4, 6, and 8 characters in length both with or without the # prefix. Input is case-insensitive.
    /// ```
    /// // #RGB
    /// Color(hex: "#FFF") == Color.white
    /// // #RGBA
    /// Color(hex: "#FFF9") == Color.white.opacity(0.6)
    /// // #RRGGBB
    /// Color(hex: "#FFFFFF") == Color.white
    /// // #RRGGBBAA
    /// Color(hex: "#FFFFFF99") == Color.white.opacity(0.6)
    /// ```
    /// The 3 and 4 character hex initializers act as shorthand syntax for their 6 and 8 character counterparts. This function conforms to
    /// [standard CSS syntax](https://developer.mozilla.org/en-US/docs/Web/CSS/hex-color#syntax).
    /// - Parameter string: A hexadecimal value representing a color.
    init(hex string: String) {
        var string: String = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        string.removePrefix("#")
        
        let scanner = Scanner(string: string)
        
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        
        // #RGB || #RGBA
        if string.count == 3 || string.count == 4 {
            let expandedString = {
                string.map {
                    "\($0)\($0)"
                }.joined()
            }()
            
            self.init(hex: expandedString)
            
            // #RRGGBB
        } else if string.count == 6 {
            let mask = 0x0000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask
            
            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            
            self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
            
            // #RRGGBBAA
        } else if string.count == 8 {
            let mask = 0x000000FF
            let r = Int(color >> 24) & mask
            let g = Int(color >> 16) & mask
            let b = Int(color >> 8) & mask
            let a = Int(color) & mask
            
            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            let alpha = Double(a) / 255.0
            
            self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
            
            // Fall-back to black
        } else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        }
    }
}

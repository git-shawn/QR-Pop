//
//  ColorContrast.swift
//  QR Pop (macOS)
//
//  Based on this formula by W3:
//  https://www.w3.org/TR/WCAG20-TECHS/G18.html#G18-tests
//
//  Adapted from a SO answer by Mobile Dan
//  https://stackoverflow.com/a/42355779
//
//  Created by Shawn Davis on 10/23/21.
//

import SwiftUI

extension Color {
    
    /// Determine the contrast ratio between two numbers
    /// - Parameters:
    ///   - color1: A color to compare the contrast ratio of
    ///   - color2: A color to compare the contrast ratio of
    /// - Returns: The contrast ratio
    static func contrastRatio(between color1: Color, and color2: Color) -> CGFloat {
        
        let luminance1 = color1.luminance()
        let luminance2 = color2.luminance()
        
        let luminanceDarker = min(luminance1, luminance2)
        let luminanceLighter = max(luminance1, luminance2)
        
        return (luminanceLighter + 0.05) / (luminanceDarker + 0.05)
    }
    
    /// Determines the contrast ratio between this color and another color
    /// - Parameter color: The color to compare against
    /// - Returns: The contrast ratio between the colors
    func contrastRatio(with color: Color) -> CGFloat {
        return Color.contrastRatio(between: self, and: color)
    }
    
    /// Determine a color's luminance
    /// - Parameter color: The color to determine the luminance of
    /// - Returns: Luminance value
    func luminance() -> CGFloat {
        guard let cgColor = self.cgColor else {
            print("An error occured converting Color to CGColor in ColorContrast.swift's luminance().")
            return 0
        }
        let ciColor = CIColor(cgColor: cgColor)
        
        func adjust(colorComponent: CGFloat) -> CGFloat {
            return (colorComponent < 0.04045) ? (colorComponent / 12.92) : pow((colorComponent + 0.055) / 1.055, 2.4)
        }

        return 0.2126 * adjust(colorComponent: ciColor.red) + 0.7152 * adjust(colorComponent: ciColor.green) + 0.0722 * adjust(colorComponent: ciColor.blue)
    }
}

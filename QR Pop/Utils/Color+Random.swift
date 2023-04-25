//
//  Color+Random.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/12/23.
//

import SwiftUI

extension Color {
    
    /// A random system `Color` excluding shades of black, white, and gray.
    static var random: Color {
        let colors: [Color] = [.red, .blue, .green, .brown, .cyan, .indigo, .mint, .orange, .pink, .purple, .teal, .yellow]
        return colors.randomElement() ?? .accentColor
    }
}

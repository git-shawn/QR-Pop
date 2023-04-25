//
//  Color+Codable.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#elseif os(macOS)
import AppKit
#endif
import SwiftUI
import OSLog

fileprivate extension Color {
    
    var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
#if os(macOS)
        PlatformColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
#else
        guard PlatformColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
            Color.logger.error("Could not find RGBA values for Color to encode.")
            return nil
        }
#endif
        
        return (r, g, b, a)
    }
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)
        
        self.init(red: r, green: g, blue: b)
    }
    
    public func encode(to encoder: Encoder) throws {
        guard let colorComponents = self.colorComponents else {
            Color.logger.error("Color could not be encoded.")
            return
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(colorComponents.red, forKey: .red)
        try container.encode(colorComponents.green, forKey: .green)
        try container.encode(colorComponents.blue, forKey: .blue)
    }
    
    private static let logger = Logger(
        subsystem: Constants.bundleIdentifier,
        category: "color+codable"
    )
}

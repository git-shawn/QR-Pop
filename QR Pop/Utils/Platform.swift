//
//  Platform.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/10/23.
//

//MARK: Bridge macOS

#if canImport(AppKit)
import AppKit
import SwiftUI

public typealias PlatformImage = NSImage
public typealias PlatformColor = NSColor

// MARK: PlatformImage macOS
extension NSImage {
    var cgImage: CGImage? {
        var proposedRect = CGRect(origin: .zero, size: size)
        
        return cgImage(
            forProposedRect: &proposedRect,
            context: nil,
            hints: nil)
    }
    
    /// Returns a data object that contains the specified image in PNG format.
    /// - Parameter image: The original image data.
    /// - Returns: A data object containing the `PNG` data, or nil if there was a problem generating the data.
    /// This function begins as a `TIFF` representation and thus uses the associated `TIFF` compression option.
    func pngData() -> Data? {
        guard let tiffRep = self.tiffRepresentation else { return nil }
        guard let bitmapData = NSBitmapImageRep(data: tiffRep) else { return nil }
        return bitmapData.representation(using: .png, properties: [:])
    }
    
    /// Creates a new image using the contents of the provided image.
    /// - Parameter cgImage: The source image.
    convenience init(cgImage: CGImage) {
        self.init(cgImage: cgImage, size: .zero)
    }
    
    convenience init(contentsOfFile: String) {
        self.init(contentsOf: URL(string: contentsOfFile)!)!
    }
    
    enum PlatformImageError: Error, LocalizedError {
        case drawError
    }
}

extension Image {
    
    /// Creates a SwiftUI image from an AppKit image instance.
    /// - Parameter platformImage: The AppKit image, as PlatformImage, to wrap with a SwiftUI Image instance.
    init(platformImage: PlatformImage) {
        self.init(nsImage: platformImage)
    }
}

// MARK: NSColor to Color
extension Color {
    static var groupedBackground = Color("Grouped")
    static var secondaryGroupedBackground = Color("SecondaryGrouped")
    static var placeholder = Color(nsColor: .placeholderTextColor)
}

// MARK: UISizeClass for macOS
// Credit: https://stackoverflow.com/a/63526479/20422552 

enum UserInterfaceSizeClass {
    case compact
    case regular
}

struct HorizontalSizeClassEnvironmentKey: EnvironmentKey {
    static let defaultValue: UserInterfaceSizeClass = .regular
}
struct VerticalSizeClassEnvironmentKey: EnvironmentKey {
    static let defaultValue: UserInterfaceSizeClass = .regular
}

extension EnvironmentValues {
    var horizontalSizeClass: UserInterfaceSizeClass {
        get { return self[HorizontalSizeClassEnvironmentKey.self] }
        set { self[HorizontalSizeClassEnvironmentKey.self] = newValue }
    }
    var verticalSizeClass: UserInterfaceSizeClass {
        get { return self[VerticalSizeClassEnvironmentKey.self] }
        set { self[VerticalSizeClassEnvironmentKey.self] = newValue }
    }
}

// MARK: UserInterfaceIdiom for macOS

class UIDevice {
    static var current = UIDevice()
    private init() {}
    
    var userInterfaceIdiom: UIUserInterfaceIdiom = .mac
    
    enum UIUserInterfaceIdiom {
        case phone, pad, tv, carplay, mac, unspecified
    }
}

#endif

// MARK: - Bridge iOS

#if canImport(UIKit)
import UIKit
import SwiftUI

public typealias PlatformImage = UIImage
public typealias PlatformColor = UIColor

// MARK: PlatformImage iOS

extension UIImage {
    
    enum PlatformImageError: Error, LocalizedError {
        case drawError
    }
}

extension Image {
    
    init(platformImage: PlatformImage) {
        self.init(uiImage: platformImage)
    }
}

#if !os(watchOS) && !os(tvOS)
// MARK: UIColor to Color
extension Color {
    static var groupedBackground = Color(uiColor: .systemGroupedBackground)
    static var secondaryGroupedBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static var placeholder = Color(uiColor: .placeholderText)
}
#endif
#endif

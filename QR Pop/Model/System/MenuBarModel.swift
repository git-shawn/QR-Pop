//
//  MenuBarModel.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/22/23.
//

#if os(macOS)
import SwiftUI
import Quartz
import QRCode
import OSLog

struct MenuBarModel {
    var hasCaptureAccess: Bool {
        CGRequestScreenCaptureAccess()
    }
    
    /// Captures the entire primary display and returns an array of `Strings` representing the encoded data within any QR codes present on the screen at the moment of capture.
    /// - Throws: An error if the screen is unable to be captured.
    /// - Returns: An array of `Strings` containing encoded QR code data. If no QR codes were able to be decoded, this array will be empty.
    ///
    /// This function only captures the *main display* as defined in Core Graphic's `CGMainDisplayID()`.
    /// This will almost always be the display the user is interacting with.
    func captureAndScanMainDisplay() throws -> [String] {
        guard let capture = CGDisplayCreateImage(CGMainDisplayID()) else {
            throw MenuBarError.captureError
        }
        // Make app active before returning result.
        NSApplication.shared.activate(ignoringOtherApps: true)
        return sanitizeQRCodeFeatures(QRCode.DetectQRCodes(capture))
    }
    
    /// Captures a region of the primary display and returns an array of `Strings` representing the encoded data within any QR codes present ont he screen at the moment of capture.
    /// - Returns: An array of `Strings` containing encoded QR code data. If no QR codes were able to be decoded, this array will be empty.
    func captureAndScanRegion() throws -> [String] {
        // Save the image in a neutral, public directory
        let tempDirectory = FileManager.default.urls(for: .sharedPublicDirectory, in: .allDomainsMask)[0]
        let resultURL = captureRegion(tempDirectory)
        
        guard resultURL == tempDirectory,
              let nsImage = NSImage(contentsOf: resultURL),
              let cgImage = nsImage.cgImage,
              ((try? FileManager.default.removeItem(at: resultURL)) != nil)
        else {
            Logger.logView.error("MenuBar: Could not capture a region of the screen.")
            throw MenuBarError.captureError
        }
        
        
        // Make app active before returning result.
        NSApplication.shared.activate(ignoringOtherApps: true)
        return sanitizeQRCodeFeatures(QRCode.DetectQRCodes(cgImage))
    }
    
    /// Removes any empty strings from an array of `CIQRCodeFeatures`.
    /// - Parameter features: An array of features.
    /// - Returns: Meaningful `Strings` found in the array.
    private func sanitizeQRCodeFeatures(_ features: [CIQRCodeFeature]) -> [String] {
        var resultsArray: [String] = []
        features.forEach { feature in
            if let string = feature.messageString, !string.isEmpty {
                resultsArray.append(string)
            }
        }
        return resultsArray
    }
    
    
    /// Captures a region and saves the capture to a destination path.
    /// - Parameter destination: The path to save the screen capture in.
    /// - Returns: The location where the caption was saved.
    ///
    /// Credit: https://github.com/nirix/swift-screencapture/blob/master/ScreenCapture/ScreenCapture.swift
    private func captureRegion(_ destination: URL) -> URL {
        let destinationPath = destination.path as String
        
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-r", destinationPath]
        task.launch()
        task.waitUntilExit()
        
        return destination
    }
}

// MARK: - Error Handling

extension MenuBarModel {
    
    enum MenuBarError: Error, LocalizedError {
        case captureError
        
        public var errorDescription: String? {
            switch self {
            case .captureError:
                return "QR Pop could not capture an image of the display to scan."
            }
        }
    }
}
#endif

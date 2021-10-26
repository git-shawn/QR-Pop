//
//  ImageSaver.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/23/21.
//

import Foundation
import Cocoa

// A helper to manage saving an image to the file system.
class ImageSaver: NSObject {
    
    /// Called after an image was successfully saved.
    var successHandler: (() -> Void)?
    
    /// Called whenever an image is not saved.
    var errorHandler: (() -> Void)?
    
    /// Save an image to the file system.
    ///
    /// This function uses optional success and error handlers.
    ///
    /// Success handler: `ImageSaver.successHandler = { some function }`
    ///
    /// Error handler: `ImageSaver.errorHandler = { some function }`
    /// - Parameter image: The image to save to the file.
    func save(image: NSImage) {
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["png"]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = true
        savePanel.allowsOtherFileTypes = false
        savePanel.title = "Save your QR code"
        savePanel.message = "Choose a folder and a name to save your code."
        savePanel.nameFieldLabel = "File name:"
        savePanel.nameFieldStringValue = "QR Code"
        
        let response = savePanel.runModal()
        if response == NSApplication.ModalResponse.OK {
            if writeFile(image, atUrl: savePanel.url!) {
                successHandler?()
            } else {
                errorHandler?()
            }
        }
    }
    
    /// Writes an image to the filesystem at a specified URL.
    /// - Parameters:
    ///   - image: The image to save.
    ///   - url: The URL to save the image to.
    /// - Returns: True if successful, false if not.
    private func writeFile(_ image: NSImage, atUrl url: URL) -> Bool {
        guard let pngData = image.png else {
            return false
        }
        do {
            try pngData.write(to: url)
            return true
        }
        catch {
            print("error saving: \(error)")
            return false
        }
    }
}

extension NSBitmapImageRep {
    var png: Data? { representation(using: .png, properties: [:]) }
}
extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}
extension NSImage {
    /// Converts an NSImage to PNG Data
    var png: Data? { tiffRepresentation?.bitmap?.png }
}

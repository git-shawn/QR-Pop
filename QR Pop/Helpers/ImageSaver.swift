//
//  ImageWriter.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import Foundation
#if os(macOS)
import Cocoa
import UniformTypeIdentifiers
#else
import UIKit
#endif

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
    func save(imageData: Data) {
        let image = imageData.image
        
        #if os(macOS)
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png]
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
        #else
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
        #endif
    }
    
    #if os(macOS)
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
    #else
    @objc private func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler?()
            print("Unable to save image using ImageSaver.swift: \(error)")
        } else {
            successHandler?()
        }
    }
    #endif
}

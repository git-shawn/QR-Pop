//
//  ImageSaver.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/17/21.
//

import Foundation
import UIKit

/// A helper class to manage saving images to the device.
class ImageSaver: NSObject {
    
    /// Called when ImageSaver.writeToPhotoAlbum successfully completes.
    var successHandler: (() -> Void)?
    
    /// Caalled when ImageSaver.writeToPhotoAlbum fails to complete
    var errorHandler: ((Error) -> Void)?
    
    
    /// Save a UIImage to the user's photo Album
    /// - Parameter image: The image to be saved.
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc private func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}

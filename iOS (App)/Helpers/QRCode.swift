//
//  QRCode.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/17/21.
//

import Foundation
import SwiftUI

/// A helper class to facilitate the generation of QR codes.
final class QRCode {
    
    /// Correction levels for a QR Code
    enum correctionLevel {
        /// Correct up to 7% of damage
        case L
        /// Correct up to 15% of damage
        case M
        /// Correct up to 25% of damage
        case Q
        /// Correct up to 30% of damage
        case H
    }
    
    /// This function generates a QR code from a String.
    /// - Parameters:
    ///   - content: The String to encode as a QR code.
    ///   - bg: The background color for the QR code.
    ///   - fg: The foreground color for the QR code.
    ///   - correction: The QR code's error correction level.
    /// - Returns: PNG Data representing the QR code generated.
    func generate(content: String, bg: Color, fg: Color, correction: correctionLevel? = correctionLevel.L) -> Data? {
        //Create CoreImage filters for the qr code
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
    
        //Convert text input to data
        let data = content.data(using: .ascii, allowLossyConversion: false)
        
        filter.setValue(data, forKey: "inputMessage")
        switch correction {
            case .L:
                filter.setValue("L", forKey: "inputCorrectionLevel")
            case .M:
                filter.setValue("M", forKey: "inputCorrectionLevel")
            case .Q:
                filter.setValue("Q", forKey: "inputCorrectionLevel")
            case .H:
                filter.setValue("H", forKey: "inputCorrectionLevel")
            case .none:
                filter.setValue("L", forKey: "inputCorrectionLevel")
        }
        colorFilter.setValue(filter.outputImage, forKey: "inputImage")
        
        //Set the background color
        colorFilter.setValue(CIColor(color: UIColor(bg)), forKey: "inputColor1")
        
        //Set the foreground color
        colorFilter.setValue(CIColor(color: UIColor(fg)), forKey: "inputColor0")
        
        //Apply the colors
        guard let ciimage = colorFilter.outputImage else { return nil }
        
        //Increase the code's image size
        let transform = CGAffineTransform(scaleX: 15, y: 15)
        let scaledCIImage = ciimage.transformed(by: transform)
        
        //Convert CoreImage to UIImage
        let uiimage = UIImage(ciImage: scaledCIImage)
        return uiimage.pngData()!
    }
    
    func vcard() {
        
    }
}

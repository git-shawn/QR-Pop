//
//  ScanCodeIntent.swift
//  QR Pop
//
//  Created by Shawn Davis on 12/2/23.
//

import SwiftUI
import AppIntents
import OSLog
import QRCode

struct ScanCodeIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Scan QR Code"
    static var description = IntentDescription("Extract data contained within a QR Code.",
    categoryName: "Scanner",
    searchKeywords: ["QR", "Code", "Scan", "Scanner", "Decode"])
    
    @Parameter(
        title: "Image",
        description: "Image to scan",
        supportedTypeIdentifiers: ["public.image"])
    var image: IntentFile
    
    static var parameterSummary: some ParameterSummary {
        Summary("Scan a QR code from an \(\.$image)")
    }
    
    func perform() async throws -> some ReturnsValue<String> {
        guard let platformImage = PlatformImage(data: image.data),
              let resultsArray = QRCode.DetectQRCodes(in: platformImage),
              let result = resultsArray.first,
              let resultString = result.messageString
        else {
            Logger.logIntent.notice("ScanCodeIntent: The image could not be scanned.")
            throw $image.needsValueError("A scannable QR code could not be found in the selected image. Please choose another.")
        }
        return .result(value: resultString)
    }
}

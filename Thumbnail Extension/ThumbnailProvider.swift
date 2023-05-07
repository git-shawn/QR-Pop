//
//  ThumbnailProvider.swift
//  Thumbnail iOS
//
//  Created by Shawn Davis on 4/21/23.
//

import UIKit
import QuickLookThumbnailing
import OSLog

class ThumbnailProvider: QLThumbnailProvider {
    
    override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
        
        let dimension = min(request.maximumSize.width, request.maximumSize.height)
        let maximumSize = CGSize(width: dimension, height: dimension)
        
        handler(QLThumbnailReply(contextSize: maximumSize, currentContextDrawing: { () -> Bool in
            
            guard let data = try? Data(contentsOf: request.fileURL),
                  let template = try? TemplateModel(fromData: data)
            else {
                Logger(subsystem: Constants.bundleIdentifier, category: "thumbnail").error("Failed to load template model from file URL.")
                return false
            }
            
            let model = QRModel(design: template.design, content: BuilderModel())
            
            guard let uiImage = model.platformImage(for: Int(dimension)) else {
                Logger(subsystem: Constants.bundleIdentifier, category: "thumbnail").error("Failed to create image for QR code.")
                return false
            }
            
            uiImage.draw(in: CGRect(origin: .zero, size: maximumSize))
            
            Logger.logView.debug("ThumbnailProvider: Thumbnail rendered successfully.")
            
            return true
            
        }), nil)
    }
}

//
//  PreviewProvider.swift
//  Quicklook iOS
//
//  Created by Shawn Davis on 4/20/23.
//

#if canImport(Quartz)
import Cocoa
import Quartz
#else
import QuickLook
#endif

class PreviewProvider: QLPreviewProvider, QLPreviewingController {
    
    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
    
        let contentType = UTType.pdf
        
        let reply = QLPreviewReply.init(dataOfContentType: contentType, contentSize: CGSize.init(width: 800, height: 800)) { (replyToUpdate : QLPreviewReply) in

            #if os(iOS)
            guard request.fileURL.startAccessingSecurityScopedResource() else { throw QuicklookError.badAccess }
            let data = try Data(contentsOf: request.fileURL)
            request.fileURL.stopAccessingSecurityScopedResource()
            #else
            let data = try Data(contentsOf: request.fileURL)
            #endif
            
            let templateModel = try TemplateModel(fromData: data)
            let qrModel = QRModel(design: templateModel.design, content: BuilderModel())
            let pdfData = try qrModel.pdfData()
            
            return pdfData
        }
                
        return reply
    }
    
    private enum QuicklookError: Error, LocalizedError {
        case badAccess
    }

}

//
//  FileDocument+QRPop.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI
import UniformTypeIdentifiers
import OSLog

struct DataFileDocument: FileDocument {
    static var readableContentTypes = [UTType.pdf, UTType.svg, UTType.png, UTType.qrpt, UTType.plainText]
    static var writableContentTypes = [UTType.pdf, UTType.svg, UTType.png, UTType.qrpt, UTType.plainText]
    
    var contentData = Data()
    
    init(initialData: Data) {
        contentData = initialData
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            contentData = data
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: contentData)
    }
}

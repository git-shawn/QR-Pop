//
//  SceneModel.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/10/23.
//

import SwiftUI
import UniformTypeIdentifiers

/// The App Model class observes, records, and interprets app-wide information in a scene-conscious way.
class SceneModel: ObservableObject {
    @Published var toaster: Toast?
    @Published var exporter: ExportableFile?
    
    // MARK: - Toasting
    
    enum Toast: Equatable {
        case error(note: String?)
        case success(note: String?)
        case copied(note: String?)
        case saved(note: String?)
        case custom(image: Image, imageColor: Color?, title: String, note: String?)
    }
    
    //MARK: - File Exporting
    
    /// A container for transporting exportable file data to the `.fileExporter` view modifier.
    struct ExportableFile: Equatable {
        static func == (lhs: SceneModel.ExportableFile, rhs: SceneModel.ExportableFile) -> Bool {
            lhs.document.contentData == rhs.document.contentData
        }
        
        var document: DataFileDocument
        var UTType: UTType
        var defaultName: String
    }
    
    /// Calls the file exporter with a file of a specified Uniform Type.
    /// - Parameters:
    ///   - data: The data to export.
    ///   - type: The file type of the exported data. Must conform to ``DataFileDocument``.
    ///   - named: The default name to be shown.
    func exportData(_ data: Data, type: UTType, named: String) {
        exporter = ExportableFile(document: DataFileDocument(initialData: data), UTType: type, defaultName: named)
    }
}

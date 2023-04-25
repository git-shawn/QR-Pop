//
//  FileExporter.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct QRFileExporterModifier: ViewModifier {
    
    @Binding var exportableFile: SceneModel.ExportableFile?
    @State var shouldShowExporter: Bool = false
    
    func body(content: Content) -> some View {
        content
            .fileExporter(
                isPresented: $shouldShowExporter,
                document: exportableFile?.document,
                contentType: exportableFile?.UTType ?? .content,
                defaultFilename: exportableFile?.defaultName,
                onCompletion: {_ in })
            .onChange(of: exportableFile, perform: { _ in
                if exportableFile != nil {
                    shouldShowExporter = true
                }
            })
    }
}

// MARK: - View Extension

extension View {
    
    /// Presents a toast overlaying the modified View.
    /// - Parameter toast: The ``SceneModel.Toast`` to overlay.
    func fileExporter(_ file: Binding<SceneModel.ExportableFile?>) -> some View {
        modifier(QRFileExporterModifier(exportableFile: file))
    }
}

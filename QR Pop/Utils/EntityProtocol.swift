//
//  EntityProtocol.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/13/23.
//

import SwiftUI

/// A type containing a collection of known values unique to Core Data entities.
protocol Entity: Equatable {
    var id: UUID? { get set }
    var title: String? { get set }
    var created: Date? { get set }
    var design: Data? { get set }
    var logo: Data? { get set }
#if !EXTENSION && !CLOUDEXT
    associatedtype EntityModelConverted: EntityConvertible & Transferable
    func asModel() throws -> EntityModelConverted
    func asExportable() throws -> SceneModel.ExportableFile
#endif
}

#if !EXTENSION && !CLOUDEXT
protocol EntityConvertible {
    var viewRepresentation: QRCodeView { get }
}

extension QREntity: Entity {
    
    func asModel() throws -> QRModel {
        return try QRModel(withEntity: self)
    }
    
    func asExportable() throws -> SceneModel.ExportableFile {
        let data = try self.asModel().pngData(for: 1024)
        return .init(document: DataFileDocument(
            initialData: data),
            UTType: .png,
            defaultName: self.title ?? "QR Code")
    }
}

extension TemplateEntity: Entity {
    func asModel() throws -> TemplateModel {
        return try TemplateModel(withEntity: self)
    }
    
    func asExportable() throws -> SceneModel.ExportableFile {
        guard let data = try self.asModel().asData() else {
            throw QRPopError.nilOptional("Could not unwrap TemplateEntity model data.")
        }
        return .init(document: DataFileDocument(
            initialData: data),
            UTType: .qrpt,
            defaultName: self.title ?? "QR Code")
    }
}
#endif

//
//  TemplateModel.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/10/23.
//

import CoreData
import SwiftUI
import UniformTypeIdentifiers
import OSLog

/// Bridges QR Pop with Core Data's `TemplateEntity` while maintaing reactive design.
struct TemplateModel: Hashable, Identifiable {
    var title: String
    var created: Date
    var logo: Data?
    var design: DesignModel
    let id: UUID
}

// MARK: - Init

extension TemplateModel {
    
    /// Loads a `TemplateModel` from `Data`.
    /// - Parameter data: Some  `.JSON` or `.QRPT` data representing a `TemplateModel`.
    init(fromData data: Data) throws {
        let decoder = JSONDecoder()
        var model = try decoder.decode(TemplateModel.self, from: data)
#if canImport(CoreImage)
        try? model.design.setLogo(model.logo)
#endif
        self = model
    }
    
#if !EXTENSION && !CLOUDEXT
    /// Transforms a `TemplateEntity` into a `TemplateModel` containing a decoded `DesignModel`.
    /// - Warning: Calling this initializer does **not** increment the entity's `viewed` property.
    /// - Parameter entity: A `TemplateEntity` stored in the database.
    init(entity: TemplateEntity) throws {
        self.title = entity.title ?? "Template"
        self.created = entity.created ?? Date()
        self.logo = entity.logo
        self.id = entity.id ?? UUID()
        guard let data = entity.design else {
            TemplateModel.logger.warning("Template Model was initiated with invalid data provided by a CoreData entity.")
            throw TemplateModelError.invalidInput
        }
        self.design = try DesignModel(decoding: data, with: entity.logo)
    }
#endif
}

// MARK: - Functions

extension TemplateModel {
    
    /// The QR code described by this model as a SwiftUI Image. No data is encoded.
    /// - Parameter dimension: The width/height dimension for the exported image.
    /// - Returns: An Image.
    func preview(for dimension: Int) -> Image? {
        var model = QRModel(design: design, content: BuilderModel())
        model.design.errorCorrection = .low
        return model.image(for: dimension)
    }
    
#if !EXTENSION
    
    /// Convert this `TemplateModel` into a `TemplateEntity` within the given context.
    /// - Parameter context: The `NSManagedObjectContext` to create the entity in.
    /// - Returns: The created entity.
    ///
    /// - Warning: This function calls `context.save()`.
    @discardableResult func insertIntoContext(_ context: NSManagedObjectContext) throws -> TemplateEntity {
        let entity = TemplateEntity(context: context)
        entity.id = UUID()
        entity.created = Date()
        entity.viewed = Date()
        entity.title = self.title
        entity.logo = self.logo
        entity.design = try self.design.asData()
        try context.save()
        return entity
    }
#endif
}

// MARK: - Conform to Codable

extension TemplateModel: Codable {
    
    /// - Returns: This template, as `JSON` data.
    func asData() -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
}

// MARK: - Conform to Transferable

extension TemplateModel: Transferable {
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .qrpt)
    }
}

// MARK: - Define File Type

extension UTType {
    /**
     A QR Pop Template
     
     **UTI:** shwndvs.QR-Pop.TemplateData
     
     **conforms to:** public.data
     */
    static var qrpt: UTType { UTType(exportedAs: "shwndvs.QR-Pop.TemplateData") }
}


// MARK: - Error Handling

extension TemplateModel {
    
    enum TemplateModelError: Error, LocalizedError {
        case decodingFailure, invalidInput
    }
    
    private static let logger = Logger(
        subsystem: Constants.bundleIdentifier,
        category: "templateModel"
    )
}

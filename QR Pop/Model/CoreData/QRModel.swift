//
//  QRModel.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/10/23.
//

import SwiftUI
import QRCode
import CoreData
import OSLog
import UniformTypeIdentifiers

/// Bridges QR Pop with Core Data's `QREntity` while maintaing reactive design.
struct QRModel: Hashable, Equatable {
    var title: String?
    var created: Date?
    var design: DesignModel
    var content: BuilderModel
    var id: UUID?
}

// MARK: - Init

extension QRModel {
    
    init() {
        self.init(design: DesignModel(), content: BuilderModel())
    }
    
#if !EXTENSION
    init(withEntity entity: QREntity) throws {
        let decoder = JSONDecoder()
        guard let designData = entity.design, let builderData = entity.builder else {
            Logger.logModel.error("QRModel: A valid QREntity object could not be deocded.")
            throw QRModelError.decodingFailure
        }
        
        var qrModel = QRModel()
        qrModel.content = try decoder.decode(BuilderModel.self, from: builderData)
        qrModel.design = try decoder.decode(DesignModel.self, from: designData)
#if canImport(CoreImage)
        if (entity.logo != nil && !(entity.logo?.isEmpty ?? true)) {
            assert(entity.logo != nil)
            try qrModel.design.setLogo(entity.logo)
        }
#endif
        qrModel.title = entity.title
        qrModel.created = entity.created
        qrModel.id = entity.id
        
        self = qrModel
    }
#endif
}

// MARK: - Interface with QRCode

extension QRModel {
    /// A `QRCode.Document` representing the model.
    private var qrCodeDoc: QRCode.Document {
        let doc = QRCode.Document(utf8String: content.result)
        doc.design = design.qrCodeDesign
        doc.errorCorrection = design.errorCorrection
#if canImport(CoreImage)
        doc.logoTemplate = design.getLogoTemplate()
#endif
        
        return doc
    }
}

//MARK: - Exporting

extension QRModel {
    
    /// `.PNG` data for the image described by this model.
    /// - Parameter dimension: The width/height dimension for the exported image.
    /// - Returns: `.PNG` data representing a QR code.
    func pngData(for dimension: Int) throws -> Data {
        guard let data = qrCodeDoc.pngData(dimension: dimension) else {
            Logger.logModel.notice("QRModel: PNG data could not be generated.")
            throw QRModelError.renderFailure
        }
        return data
    }
    
    /// `.JPEG` data for the image described by this model.
    /// - Parameters:
    ///   - dimension: The width/height dimension for the exported image.
    ///   - compression: The compression level, between `0.0 – 1.0`, with `1.0` representing the highest possible quality.
    /// - Returns: `.JPEG` data representing a QR code.
    func jpegData(for dimension: Int, compression: Double = 0.8) throws -> Data {
        guard let data = qrCodeDoc.jpegData(dimension: dimension, compression: compression) else {
            Logger.logModel.notice("QRModel: JPEG data could not be generated.")
            throw QRModelError.renderFailure
        }
        return data
    }
    
    /// `.PDF` data for the image described by this model.
    /// - Parameter dimension: The width/height dimension for the exported image, defaulting to `256`. As a *vector*, this value not be important.
    /// - Returns: `.PDF` data representing a QR code.
    func pdfData(for dimension: Int = 256) throws -> Data {
        guard let data = qrCodeDoc.pdfData(dimension: dimension) else {
            Logger.logModel.notice("QRModel: PDF data could not be generated.")
            throw QRModelError.renderFailure
        }
        return data
    }
    
    /// `.SVG` data for the image described by this model.
    /// - Parameter dimension: The width/height dimension for the exported image, defaulting to `256`. As a *vector*, this value not be important.
    /// - Returns: `.SVG` data representing a QR code.
    func svgData(for dimension: Int = 256) throws -> Data {
        guard let data = qrCodeDoc.svgData(dimension: dimension) else {
            Logger.logModel.notice("QRModel: SVG data could not be generated.")
            throw QRModelError.renderFailure
        }
        return data
    }
    
#if os(iOS)
    
    /// Adds an image of the QR code described by this model to the default pasteboard.
    /// - Parameter dimension: The width/height dimension for the exported image.
    func addToPasteboard(for dimension: Int) {
        qrCodeDoc.addToPasteboard(CGSize(width: dimension, height: dimension))
    }
    
#endif
    
#if os(iOS)
    
    /// Adds an image of the QR code described by this model to the Photos app.
    /// - Parameter dimensions: The width/height dimension for the exported image.
    /// - Warning: This function is not available for macOS.
    func addToPhotoLibrary(for dimensions: Int) throws {
        guard let image = platformImage(for: dimensions) else {
            Logger.logModel.notice("QRModel: A PlatformImage could not be generated.")
            throw QRModelError.exportFailure
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
#endif
    
    /// The QR code described by this model as a `PlatformImage`.
    /// - Parameter dimension: The width/height dimension for the exported image.
    /// - Returns: `NSImage` when using `AppKit`, `UIImage` when using `UIKit`.
    func platformImage(for dimension: Int) -> PlatformImage? {
        return qrCodeDoc.platformImage(dimension: dimension)
    }
    
    /// The QR code described by this model as a SwiftUI `Image`.
    /// - Parameter dimension: The width/height dimension for the exported image.
    /// - Returns: An Image.
    func image(for dimension: Int) -> Image? {
        return qrCodeDoc.imageUI(CGSize(width: dimension, height: dimension), label: Text("QR Code"))
    }
}

#if !EXTENSION && !CLOUDEXT

// MARK: Manipulating

extension QRModel {
    
    /// Compares the known value of the QR code described by this model to the scan results of an image representation of it.
    /// If the image cannot be generated, cannot be scanned, or if the scanned results do not match the test fails.
    /// - Returns: `true` if the code can be scanned, `false` if not.
    func testScannability() -> Bool {
        if let cgImage = qrCodeDoc.cgImage(dimension: 512),
           let feature =  QRCode.DetectQRCodes(cgImage).first,
           let content = feature.messageString,
           content == self.content.result
        {
            return true
        } else {
            return false
        }
    }
    
    /// Resets data stored within this QR Model.
    ///
    /// This function does not alter identifying information such as the `created`, `id`, and `title` properties.
    mutating func reset() {
        content.resetData()
        design = DesignModel()
    }
    
    /// Creates a ``QREntity`` in the given context based on the values of this model.
    /// - Parameter context: An NSManagedObjectContext to create the entity in.
    /// - Returns: The entity created.
    /// - Warning: This function does **not** call `NSManagedObjectContext.save()`.
    @discardableResult func placeInCoreData(context: NSManagedObjectContext) throws -> QREntity {
        let entity = QREntity(context: context)
        entity.created = Date()
        entity.id = UUID()
        entity.design = try self.design.asData()
        entity.builder = try self.content.asData()
        entity.logo = self.design.logo
        entity.title = self.title
        
        return entity
    }
    
    /// Creates a ``QREntity`` in the given context based on the values of this model.
    /// - Parameter context: An NSManagedObjectContext to create the entity in.
    /// - Returns: The entity created.
    /// - Warning: This function saves the newly created entity with `NSManagedObjectContext.save()`.
    @discardableResult func placeInCoreDataAndSave(context: NSManagedObjectContext) throws -> QREntity {
        let entity = try placeInCoreData(context: context)
        try Persistence.shared.container.viewContext.atomicSave()
        return entity
    }
}

#endif

// MARK: - Conform to EntityConvertible

#if !EXTENSION && !CLOUDEXT
extension QRModel: EntityConvertible {
    
    var viewRepresentation: QRCodeView {
        QRCodeView(qrcode: .constant(self))
    }
}
#endif

// MARK: - Conform to Transferable

extension QRModel: Transferable {
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { model in
            try model.pngData(for: 512)
        }
    }
}

// MARK: - Conform to Codable

extension QRModel: Codable {
    
}

// MARK: - Scene Focusable

struct FocusedQRModelKey: FocusedValueKey {
    typealias Value = Binding<QRModel>
}

extension FocusedValues {
    var qrModel: FocusedQRModelKey.Value? {
        get { self[FocusedQRModelKey.self] }
        set { self[FocusedQRModelKey.self] = newValue }
    }
}

// MARK: - Error Handling

extension QRModel {
    
    enum QRModelError: Error, LocalizedError {
        case renderFailure, decodingFailure, exportFailure
    }
}

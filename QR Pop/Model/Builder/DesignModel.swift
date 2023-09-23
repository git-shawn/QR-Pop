//
//  DesignModel.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/10/23.
//

import SwiftUI
import QRCode
import CoreData
import OSLog
import AppIntents

/// Accepts and interprets data submitted to DesignView.
struct DesignModel: Hashable, Equatable {
    var eyeShape: EyeShape
    var pixelShape: PixelShape
    var eyeColor: Color
    var pupilColor: Color
    var pixelColor: Color
    var backgroundColor: Color
    var offPixels: PixelShape?
    var errorCorrection: QRCode.ErrorCorrection
    var logoPlacement: PlacementPosition = .center
    var logo: Data?
}

//MARK: - Init

extension DesignModel {
    
    init() {
        self.init(eyeShape: .square, pixelShape: .square, eyeColor: .black, pupilColor: .black, pixelColor: .black, backgroundColor: .white, offPixels: nil, errorCorrection: .medium, logo: nil)
    }
    
    /// Initiates a ``DesignModel`` with a some given `JSON` data.
    /// The `logo` parameter is not included in `DesignModel`s codable representation, so it must be set seperately.
    /// - Parameters:
    ///   - data: `Data` representing a ``DesignModel``
    ///   - logo: `Data` repsenting the `logo` parameter.
    init(decoding data: Data, with logo: Data? = nil) throws {
        let decoder = JSONDecoder()
        var model = try decoder.decode(DesignModel.self, from: data)
        model.logo = logo
        self = model
    }
}

//MARK: - Placement Position

extension DesignModel {
    
    /// The location within a QR code that the logo will be placed.
    enum PlacementPosition: Int, Codable {
        case center, bottomTrailing
    }
}

//MARK: - Functions

extension DesignModel {
#if canImport(CoreImage)
    
    /// Returns the logo as an `Image` with no masking effects.
    /// - Returns: An Image of the logo, if any.
    func resolvingLogo() -> Image? {
        guard let logo = logo,
              let platformImage = PlatformImage(data: logo),
              let placedImage = try? platformImage.place(in: CGSize(width: 512, height: 512), at: logoPlacement)
        else { return nil }
        return Image(platformImage: placedImage)
    }
    
    /// Get a `QRCode.LogoTemplate` described by this model.
    /// - Parameter position: The position to place the logo at.
    /// - Returns: A `QRCode.LogoTemplate`
    func getLogoTemplate(placedAt position: PlacementPosition) throws -> QRCode.LogoTemplate {
        guard let logo = logo,
              let platformImage = PlatformImage(data: logo),
              let placedImage = try? platformImage.place(in: CGSize(width: 512, height: 512), at: position),
              let cgImage = placedImage.cgImage
        else {
            throw DesignModelError.logoFailure
        }
        
        return QRCode.LogoTemplate(image: cgImage)
    }
    
    /// Get a `QRCode.LogoTemplate` described by this model.
    /// - Returns: A `QRCode.LogoTemplate`
    func getLogoTemplate() -> QRCode.LogoTemplate {
        let template: QRCode.LogoTemplate = (try? getLogoTemplate(placedAt: logoPlacement)) ?? QRCode.LogoTemplate(image: PlatformImage(named: "EmptyImage")!.cgImage!)
        return template
    }
    
    /// Applies an image overlay to this design.
    /// - Parameter data: The image to apply, as data.
    mutating func setLogo(_ data: Data?) throws {
        guard let data = data,
              let platformImage = PlatformImage(data: data),
              let scaledImage = try? platformImage.resized(to: CGSize(width: 256, height: 256))
        else {
            self.logo = nil
            Logger.logModel.notice("DesignModel: Attempted to set invalid data as logo.")
            throw DesignModelError.logoFailure
        }
        
        self.logo = scaledImage.pngData()
    }
    
    /// Rotate the logo, if set, a certain direction.
    /// - Parameter direction: The direction to rotate, either `clockwise` or `counterclockwise`.
    mutating func rotateLogo(direction: PlatformImage.ClockwiseRotation) {
        guard let logo = logo,
              let platformImage = PlatformImage(data: logo)
        else { return }
        
        self.logo = platformImage.rotate(by: direction)?.pngData()
    }
    
#endif
    
    /// A `QRCode.Design` representing Design Model.
    /// - Warning: `QRCode.Design` does not store the ``logo`` or ``errorCorrection`` properties.
    var qrCodeDesign: QRCode.Design {
        let design = QRCode.Design()
        design.shape.eye = self.eyeShape.generator
        design.shape.onPixels = self.pixelShape.generator
        design.shape.offPixels = self.offPixels?.generator
        
        design.backgroundColor(self.backgroundColor.cgColor)
        
        design.style.eye = self.eyeColor.fillStyleGenerator
        design.style.pupil = self.pupilColor.fillStyleGenerator
        design.style.onPixels = self.pixelColor.fillStyleGenerator
        design.style.offPixels = self.pixelColor.fillStyleGenerator(withAlpha: 0.2)
        
        return design
    }
    
#if !EXTENSION && !CLOUDEXT
    
    /// Creates a `TemplateEntity` in context with this design as the `data` parameter.
    /// - Parameters:
    ///   - title: The title for the new `TemplateEntity`.
    ///   - context: The context to create it within.
    /// - Returns: The new entity.
    /// - Warning: This function **saves** its changes within the context.
    @discardableResult func createTemplate(named title: String, in context: NSManagedObjectContext) throws -> TemplateEntity {
        let entity = TemplateEntity(context: context)
        
        entity.id = UUID()
        entity.created = Date()
        entity.title = title.isEmpty ? "Template" : title
        entity.logo = self.logo
        entity.design = try self.asData()
        
        try context.atomicSave()
        return entity
    }
    
#endif
}

//MARK: - Eye Shape

extension DesignModel {
    
    enum EyeShape: String, CaseIterable, Codable, Equatable, AppEnum {
        case square, circle, squircle, roundedOuter, shield, roundedPointingOut, roundedPointingIn, leaf, barsHorizontal, barsVertical
        
        /// An SF Symbol visualizing the eye shape as an `Image`.
        var symbol: Image {
            Image("eye\(self.rawValue.uppercaseFirstLetter)")
        }
        
        /// A user-facing String describing the eye shape.
        var title: String {
            generator.title.capitalized
        }
        
        /// The eye shape's `QRCodeEyeShapeGenerator` for use within the model.
        var generator: QRCodeEyeShapeGenerator {
            switch self {
            case .square:
                return QRCode.EyeShape.Square()
            case .circle:
                return QRCode.EyeShape.Circle()
            case .squircle:
                return QRCode.EyeShape.Squircle()
            case .roundedOuter:
                return QRCode.EyeShape.RoundedOuter()
            case .shield:
                return QRCode.EyeShape.Shield()
            case .roundedPointingOut:
                return QRCode.EyeShape.RoundedPointingOut()
            case .roundedPointingIn:
                return QRCode.EyeShape.RoundedPointingIn()
            case .leaf:
                return QRCode.EyeShape.Leaf()
            case .barsHorizontal:
                return QRCode.EyeShape.BarsHorizontal()
            case .barsVertical:
                return QRCode.EyeShape.BarsVertical()
            }
        }
        
        static func == (lhs: EyeShape, rhs: EyeShape) -> Bool {
            lhs.rawValue == rhs.rawValue
        }
        
        static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Eye Shape")
        static var caseDisplayRepresentations: [Self : DisplayRepresentation] = [
            .square : "Square",
            .circle : "Circle",
            .squircle : "Squircle",
            .roundedOuter : "Rounded Outer",
            .shield : "Shield",
            .roundedPointingOut : "Rounded Pointing Out",
            .roundedPointingIn : "Rounded Pointing In",
            .leaf : "Leaf",
            .barsHorizontal : "Horizontal Bars",
            .barsVertical : "Vertical Bars",
        ]
    }
}

//MARK: - Pixel Shape

extension DesignModel {
    
    enum PixelShape: String, CaseIterable, Codable, Equatable, AppEnum {
        case square, circle, squircle, pixel, diamond, star, sparkle, flower, sharpPixel, horizontal, vertical, roundedPath, curvedPixel, sharp, insetRound
        
        /// An SF Symbol visualizing the pixel shape as an `Image`.
        var symbol: Image {
            Image("data\(self.rawValue.uppercaseFirstLetter)")
        }
        
        /// A user-facing String describing the pixel shape.
        var title: String {
            switch self {
            case .square: return "Square Path"
            case .circle: return "Circles"
            case .squircle: return "Squircles"
            case .pixel: return "Pixels"
            case .diamond: return "Diamonds"
            case .star: return "Stars"
            case .sparkle: return "Sparkles"
            case .flower: return "Flowers"
            case .sharpPixel: return "Spikes"
            case .horizontal: return "Rows"
            case .vertical: return "Columns"
            case .roundedPath: return "Rounded Path"
            case .curvedPixel: return "Curved Pixel Path"
            case .sharp: return "Sharp Path"
            case .insetRound: return "Indented Path"
            }
        }
        
        /// The pixel shape's `QRCodePixelShapeGenerator` for use within the generator.
        var generator: QRCodePixelShapeGenerator {
            switch self {
            case .square:
                return QRCode.PixelShape.Square()
            case .circle:
                return QRCode.PixelShape.Circle(insetFraction: 0.15)
            case .squircle:
                return QRCode.PixelShape.Squircle(insetFraction: 0.15)
            case .pixel:
                return QRCode.PixelShape.Square(insetFraction: 0.15)
            case .diamond:
                return QRCode.PixelShape.Square(insetFraction: 0.35, rotationFraction: 0.25)
            case .sharp:
                return QRCode.PixelShape.Pointy()
            case .horizontal:
                return QRCode.PixelShape.Horizontal(insetFraction: 0.35, cornerRadiusFraction: 1)
            case .vertical:
                return QRCode.PixelShape.Vertical(insetFraction: 0.35, cornerRadiusFraction: 1)
            case .roundedPath:
                return QRCode.PixelShape.RoundedPath(cornerRadiusFraction: 1)
            case .curvedPixel:
                return QRCode.PixelShape.CurvePixel()
            case .sharpPixel:
                return QRCode.PixelShape.Sharp(insetFraction: 0.15)
            case .star:
                return QRCode.PixelShape.Star(insetFraction: 0.15)
            case .flower:
                return QRCode.PixelShape.Flower(insetFraction: 0.15)
            case .sparkle:
                return QRCode.PixelShape.Shiny()
            case .insetRound:
                return QRCode.PixelShape.RoundedEndIndent(cornerRadiusFraction: 0.5)
            }
        }
        
        static func == (lhs: PixelShape, rhs: PixelShape) -> Bool {
            lhs.rawValue == rhs.rawValue
        }
        
        static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Pixel Shape")
        static var caseDisplayRepresentations: [Self : DisplayRepresentation] = [
            .square : "Square Path",
            .circle : "Circles",
            .squircle : "Squircles",
            .pixel : "Pixels",
            .diamond : "Diamonds",
            .star : "Stars",
            .sparkle : "Sparkles",
            .flower : "Flowers",
            .sharpPixel : "Spikes",
            .horizontal : "Rows",
            .vertical : "Columns",
            .roundedPath : "Rounded Path",
            .curvedPixel : "Curved Pixel Path",
            .sharp : "Sharp Path",
            .insetRound : "Indented Path"
        ]
    }
}

//MARK: - Codable

extension DesignModel: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case eyeShape
        case pixelShape
        case eyeColor
        case pupilColor
        case pixelColor
        case backgroundColor
        case offPixels
        case errorCorrection
        case logoPlacement
    }
    
    /// Converts this `DesignModel` to `JSON` data.
    /// - Warning: Data representations of `DesignModel`s do not include their `logo` property.
    /// - Returns: `JSON` data.
    func asData() throws -> Data {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return data
    }
}

// MARK: - Error Handling

extension DesignModel {
    
    enum DesignModelError: Error, LocalizedError {
        case logoFailure
    }
}

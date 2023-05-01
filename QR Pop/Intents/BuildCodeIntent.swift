//
//  BuildCodeIntent.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/27/23.
//

import SwiftUI
import AppIntents
import UniformTypeIdentifiers
import QRCode
import OSLog

struct BuildCodeIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Build a QR Code"
    static var description = IntentDescription("Build a QR Code using design elements from QR Pop.",
    categoryName: "Builder",
    searchKeywords: ["QR", "Code", "Pop", "Build", "Generate"])
    
    static var authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed
    
    @Parameter(
        title: "Content",
        description: "The information that the QR code will represent.")
    var content: String
    
    @Parameter(
        title: "File Type",
        description: "The file type of the QR code.",
        default: BuiltCodeFileType.png)
    var fileType: BuiltCodeFileType
    
    @Parameter(
        title: "Error Correction Level",
        description: "The amount of error correction that should be applied to the QR code.",
        default: BuildCodeErrorCorrection.medium)
    var errorCorrection: BuildCodeErrorCorrection
    
    @Parameter(
        title: "Pixel Shape",
        description: "The shape of the scannable content within the QR code.",
        default: DesignModel.PixelShape.square)
    var pixelShape: DesignModel.PixelShape
    
    @Parameter(
        title: "Pixel Color",
        description: "The color of the inner pixels, as a HEX code.",
        default: "#000000")
    var pixelColor: String
    
    @Parameter(
        title: "Eye Shape",
        description: "The shape of the three outer eyes which frame the QR code.",
        default: DesignModel.EyeShape.square)
    var eyeShape: DesignModel.EyeShape
    
    @Parameter(
        title: "Eye Color",
        description: "The color of the outer portion of each eye, as a HEX code.",
        default: "#000000")
    var eyeColor: String
    
    @Parameter(
        title: "Pupil Color",
        description: "The color of the inner portion of each eye, as a HEX code.",
        default: "#000000")
    var pupilColor: String
    
    @Parameter(
        title: "Background Color",
        description: "The background color, as a HEX code.",
        default: "#FFFFFF")
    var backgroundColor: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Generate a QR code with \(\.$content) as a \(\.$fileType)") {
            \.$pixelShape
            \.$pixelColor
            \.$eyeShape
            \.$eyeColor
            \.$pupilColor
            \.$backgroundColor
        }
    }
    
    func perform() async throws -> some ReturnsValue<IntentFile> {
        let design = DesignModel(
            eyeShape: eyeShape,
            pixelShape: pixelShape,
            eyeColor: Color(hex: eyeColor),
            pupilColor: Color(hex: pupilColor),
            pixelColor: Color(hex: pixelColor),
            backgroundColor: Color(hex: backgroundColor),
            errorCorrection: errorCorrection.qrValue)
        let builder = BuilderModel(text: content)
        let model = QRModel(design: design, content: builder)
        
        let resultFile: IntentFile = try {
            switch fileType {
            case .pdf:
                let data = try model.pdfData()
                return IntentFile(data: data, filename: "QR Code", type: .pdf)
            case .svg:
                let data = try model.svgData()
                return IntentFile(data: data, filename: "QR Code", type: .svg)
            case .png:
                let data = try model.pngData(for: 1024)
                return IntentFile(data: data, filename: "QR Code", type: .png)
            }
        }()
        
        return .result(value: resultFile) {
            BuildCodeResultView(model: model)
        }
    }
}

// MARK: - Error Correction App Enums

enum BuildCodeErrorCorrection: Int, AppEnum {
    case low
    case medium
    case quantize
    case high
    
    var qrValue: QRCode.ErrorCorrection {
        switch self {
        case .low:
            return .low
        case .medium:
            return .medium
        case .quantize:
            return .quantize
        case .high:
            return .high
        }
    }
    
    public static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Error Correction Level")
    
    public static var caseDisplayRepresentations: [BuildCodeErrorCorrection : DisplayRepresentation] = [
        .low : DisplayRepresentation(title: "Low"),
        .medium : DisplayRepresentation(title: "Medium"),
        .quantize : DisplayRepresentation(title: "Quartile"),
        .high : DisplayRepresentation(title: "Low")
    ]
}

// MARK: - Exportable File Types

enum BuiltCodeFileType: Int, AppEnum {
    case pdf
    case svg
    case png
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Export File Type")
    static var caseDisplayRepresentations: [BuiltCodeFileType : DisplayRepresentation] = [
        .pdf : DisplayRepresentation(title: "PDF"),
        .svg : DisplayRepresentation(title: "SVG"),
        .png : DisplayRepresentation(title: "PNG")
    ]
}

private struct BuildCodeResultView: View {
    let model: QRModel
    
    var body: some View {
        VStack(alignment: .center) {
            model.image(for: 512)?
                .resizable()
                .scaledToFit()
                .scenePadding()
        }
        .frame(maxWidth: .infinity, maxHeight: 256)
        .background(model.design.backgroundColor)
    }
}

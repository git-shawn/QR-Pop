//
//  BuildCodeWithTemplateIntent.swift
//  QR Pop
//
//  Created by Shawn Davis on 8/06/23.
//  User Requested Feature!
//

import SwiftUI
import AppIntents
import UniformTypeIdentifiers
import QRCode
import OSLog

struct BuildCodeWithTemplateIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Build a QR Code with a Template"
    static var description = IntentDescription("Build a QR Code using a template made in QR Pop.",
    categoryName: "Builder",
    searchKeywords: ["QR", "Code", "Pop", "Build", "Generate", "Template"])
    
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
        title: "Template",
        description: "A Template created and saved within QR Pop.",
        requestValueDialog: IntentDialog("Which template would you like to use?"),
        optionsProvider: TemplateOptionsProvider())
    var template: TemplateIntentEntity
    
    @Parameter(
        title: "Export Resolution",
        description: "The quality of the exported image, in pixels. Resolution must be between 256 and 7680.",
        default: 512,
        inclusiveRange: (256, 7680))
    var exportResolution: Int
    
    static var parameterSummary: some ParameterSummary {
        Summary("Generate a QR code with \(\.$content) using the \(\.$template) template") {
            \.$fileType
            \.$exportResolution
        }
    }
    
    func perform() async throws -> some ShowsSnippetView & ReturnsValue<IntentFile> {
        do {
            let builder = BuilderModel(text: content)
            let entity = try persistence.getTemplateEntityWithUUID(template.id)
            let templateModel = try entity.asModel()
            let model = QRModel(design: templateModel.design, content: builder)
            
            let resultFile: IntentFile = try {
                switch fileType {
                case .pdf:
                    let data = try model.pdfData(for: exportResolution)
                    return IntentFile(data: data, filename: "QR Code", type: .pdf)
                case .svg:
                    let data = try model.svgData()
                    return IntentFile(data: data, filename: "QR Code", type: .svg)
                case .png:
                    let data = try model.pngData(for: exportResolution)
                    return IntentFile(data: data, filename: "QR Code", type: .png)
                }
            }()
            
            return .result(value: resultFile) {
                BuildCodeWithTemplateResultView(model: model)
            }
        } catch {
            Logger.logIntent.notice("BuildCodeWithTemplateIntent: The user requested a template that was unreachable or that does not exist.")
            throw $template.needsValueError(IntentDialog(""))
        }
    }
}

// MARK: - Dynamic Options Provider

private struct TemplateOptionsProvider: DynamicOptionsProvider {
    
    func results() async throws -> [TemplateIntentEntity] {
        try persistence.getAllTemplateEntities()
            .map {
                guard let id = $0.id, let title = $0.title
                else {
                    // This should never happen. It would indicate a database corruption of some kind.
                    Logger.logIntent.fault("An entity was discovered in the CoreData store without an ID or Title.")
                    fatalError("Unexpectedly found nil when accessing a QRTemplate value.")
                }
                
                return TemplateIntentEntity(id: id, name: title)
            }
    }
}

// MARK: - Template Entity

struct TemplateIntentEntity: Equatable, Hashable, AppEntity {
    
    typealias DefaultQuery = TemplateQuery
    static var defaultQuery: TemplateQuery = TemplateQuery()
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "QR Code")
    
    var displayRepresentation: DisplayRepresentation {
        if let entity = try? persistence.getTemplateEntityWithUUID(id),
           let model = try? entity.asModel(),
           let imgData = try? QRModel(design: model.design, content: .init(text: "")).jpegData(for: 256) {
            return DisplayRepresentation(
                title: .init(stringLiteral: name),
                subtitle: .init(stringLiteral: model.created.formatted()),
                image: .init(data: imgData))
        } else {
            return DisplayRepresentation(stringLiteral: name)
        }
    }
    
    var id: UUID
    var name: String
}

// MARK: - Template Entity Query

struct TemplateQuery: EntityQuery, EntityStringQuery {
    typealias Entity = TemplateIntentEntity
    
    func entities(matching string: String) async throws -> [TemplateIntentEntity] {
        try persistence.getTemplateEntitiesWithTitle(string)
            .map {
                guard let id = $0.id, let title = $0.title
                else {
                    // This should never happen. It would indicate a database corruption of some kind.
                    Logger.logIntent.fault("An entity was discovered in the CoreData store without an ID or Title.")
                    fatalError("Unexpectedly found nil when accessing a QRTemplate value.")
                }
                
                return TemplateIntentEntity(id: id, name: title)
            }
    }
    
    func entities(for identifiers: [UUID]) async throws -> [TemplateIntentEntity] {
        persistence.getTemplateEntitiesWithUUIDs(identifiers)
            .map {
                guard let id = $0.id, let title = $0.title
                else {
                    // This should never happen. It would indicate a database corruption of some kind.
                    Logger.logIntent.fault("An entity was discovered in the CoreData store without an ID or Title.")
                    fatalError("Unexpectedly found nil when accessing a QRTemplate value.")
                }
                
                return TemplateIntentEntity(id: id, name: title)
            }
    }
    
    func suggestedEntities() async throws -> [TemplateIntentEntity] {
        try persistence.getAllTemplateEntities()
            .map {
                guard let id = $0.id, let title = $0.title
                else {
                    // This should never happen. It would indicate a database corruption of some kind.
                    Logger.logIntent.fault("An entity was discovered in the CoreData store without an ID or Title.")
                    fatalError("Unexpectedly found nil when accessing a QRTemplate value.")
                }
                
                return TemplateIntentEntity(id: id, name: title)
            }
    }
}

// MARK: - Results View

private struct BuildCodeWithTemplateResultView: View {
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

fileprivate var persistence = Persistence.shared

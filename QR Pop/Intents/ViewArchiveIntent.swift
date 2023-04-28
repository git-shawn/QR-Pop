//
//  ViewArchiveIntent.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/26/23.
//

import SwiftUI
import AppIntents
import OSLog

struct ViewArchiveIntent: AppIntent, PredictableIntent {
    
    init() { }
    
    init(for model: QRModel) {
        if let id = model.id, let name = model.title {
            self.code = .init(id: id, name: name)
        }
    }

    static var title: LocalizedStringResource = "View My Archive"
    static var description = IntentDescription("View a QR code saved within your Archive")
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication
    
    @Parameter(
        title: "QR Code",
        requestValueDialog: "Which code would you like to view?",
        optionsProvider: ArchiveOptionsProvider())
    var code: ArchiveIntentEntity
    
    static var parameterSummary: some ParameterSummary {
        Summary("View \(\.$code) from my Archive")
    }
    
    // This may or may not work. It's not clear how to test this.
    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$code)) { code in
            DisplayRepresentation(
                title: "View \"\(code.name)\" from your Archive")
        }
    }
    
    func perform() async throws -> some ShowsSnippetView & ProvidesDialog {
        let entity = try persistence.getQREntityWithUUID(code.id)
        let model = try QRModel(withEntity: entity)
        
        return .result(
            dialog: "Here's \"\(model.title ?? "My QR Code")\" from your Archive.",
            view: ArchiveSnippetView(model: model))
    }
}

// MARK: - Archive Snippet View

private struct ArchiveSnippetView: View {
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

// MARK: - Dynamic Options Provider

private struct ArchiveOptionsProvider: DynamicOptionsProvider {
    
    
    func results() async throws -> [ArchiveIntentEntity] {
        try persistence.getAllQREntities()
            .map {
                guard let id = $0.id, let title = $0.title
                else {
                    // This should never happen. It would indicate a database corruption of some kind.
                    Logger.logIntent.fault("An entity was discovered in the CoreData store without an ID or Title.")
                    fatalError("Unexpectedly found nil when accessing a QREntity value.")
                }
                
                return ArchiveIntentEntity(id: id, name: title)
            }
    }
}

// MARK: - Archive Entity

struct ArchiveIntentEntity: Equatable, Hashable, AppEntity {
    
    typealias DefaultQuery = ArchiveQuery
    static var defaultQuery: ArchiveQuery = ArchiveQuery()
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "QR Code")
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: .init(stringLiteral: name))
    }
    
    let id: UUID
    let name: String
}

// MARK: - Archive Entity Query

struct ArchiveQuery: EntityStringQuery {
    typealias Entity = ArchiveIntentEntity
    
    func entities(matching string: String) async throws -> [ArchiveIntentEntity] {
        try persistence.getQREntitiesWithTitle(string)
            .map {
                guard let id = $0.id, let title = $0.title
                else {
                    // This should never happen. It would indicate a database corruption of some kind.
                    Logger.logIntent.fault("An entity was discovered in the CoreData store without an ID or Title.")
                    fatalError("Unexpectedly found nil when accessing a QREntity value.")
                }
                
                return ArchiveIntentEntity(id: id, name: title)
            }
    }
    
    func entities(for identifiers: [UUID]) async throws -> [ArchiveIntentEntity] {
        persistence.getQREntitiesWithUUIDs(identifiers)
            .map {
                guard let id = $0.id, let title = $0.title
                else {
                    // This should never happen. It would indicate a database corruption of some kind.
                    Logger.logIntent.fault("An entity was discovered in the CoreData store without an ID or Title.")
                    fatalError("Unexpectedly found nil when accessing a QREntity value.")
                }
                
                return ArchiveIntentEntity(id: id, name: title)
            }
    }
}

fileprivate var persistence = Persistence.shared

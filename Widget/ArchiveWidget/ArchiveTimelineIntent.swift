//
//  ArchiveTimelineIntent.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/21/23.
//

import SwiftUI
import WidgetKit
import AppIntents

@available(watchOS 10.0, iOS 17.0, macOS 14.0, *)
struct ArchiveTimelineIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select QR Code"
    static var description = IntentDescription("Display a code from your QR Pop Archive.")
    
    @Parameter(title: "QR Code")
    var code: ArchivedCodeEntity
    
    init(code: ArchivedCodeEntity) {
        self.code = code
    }
    
    
    init() {
    }
}

struct ArchivedCodeEntity: AppEntity {
    let id: UUID
    let title: String
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "QR Code"
    static var defaultQuery = ArchivedCodeQuery()
    
//    var displayRepresentation: DisplayRepresentation {
//        if let entity = try? Persistence.shared.getQREntityWithUUID(id),
//           let model = try? QRModel(withEntity: entity),
//           let image = try? model.jpegData(for: 128) {
//            DisplayRepresentation(title: "\(title)", subtitle: "\(model.created?.formatted(date: .abbreviated, time: .omitted) ?? "")", image: .init(data: image))
//        } else {
//            DisplayRepresentation(stringLiteral: title)
//        }
//    }
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
}

struct ArchivedCodeQuery: EntityQuery {
    
    /// Returns every QR code saved within CoreData.
    func entities(for identifiers: [ArchivedCodeEntity.ID]) async throws -> [ArchivedCodeEntity] {
        try Persistence.shared.getAllQREntities().compactMap({ entity in
            guard let id = entity.id, let title = entity.title else { return nil }
            return ArchivedCodeEntity(id: id, title: title)
        })
    }
    
    /// Returns the **5** most recent QR codes saved within CoreData.
    func suggestedEntities() async throws -> [ArchivedCodeEntity] {
        try Persistence.shared.getMostRecentQREntities(5).compactMap({ entity in
            guard let id = entity.id, let title = entity.title else { return nil }
            return ArchivedCodeEntity(id: id, title: title)
        })
    }
    
    /// Returns the most recent QR code saved within CoreData.
    func defaultResult() async -> ArchivedCodeEntity? {
        guard let entity = try? Persistence.shared.getMostRecentQREntities(1).first,
                let id = entity.id,
                let title = entity.title
        else { return nil }
        return ArchivedCodeEntity(id: id, title: title)
    }
}

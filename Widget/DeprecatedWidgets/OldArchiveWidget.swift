//
//  OldArchiveWidget.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/21/23.
//

import WidgetKit
import SwiftUI
import Intents
import QRCode
import OSLog

struct OldArchiveProvider: IntentTimelineProvider {
    let moc = Persistence.shared.container.viewContext
    
    func placeholder(in context: Context) -> OldArchiveEntry {
        OldArchiveEntry(kind: .placeholder)
    }
    
    func getSnapshot(for configuration: TimelineConfigurationIntent,
                     in context: Context,
                     completion: @escaping (OldArchiveEntry) -> Void) {
        let entry = OldArchiveEntry(model: getModel(from: configuration), kind: .timeline)
        completion(entry)
    }
    
    func getTimeline(for configuration: TimelineConfigurationIntent,
                     in context: Context,
                     completion: @escaping (Timeline<OldArchiveEntry>) -> Void) {
        let entries = [OldArchiveEntry(model: getModel(from: configuration), kind: .timeline)]
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
    
    /// Get the model described by a certain configuration.
    /// - Parameter configuration: The configuration describing a QR model.
    /// - Returns: A ``QRModel``.
    func getModel(from configuration: TimelineConfigurationIntent) -> QRModel? {
        guard let qrcode = configuration.qrcode,
              let entityURIString = qrcode.identifier,
              let entityURI = URL(string: entityURIString),
              let entity = Persistence.shared.getQREntityWithURI(entityURI),
              let model = try? QRModel(withEntity: entity)
        else {
            Logger.logExtension.fault("Widget: Unable to create QRModel from Intent.")
            return nil
        }
        return model
    }
    
    func recommendations() -> [IntentRecommendation<TimelineConfigurationIntent>] {
        do {
            return try Persistence.shared.getMostRecentQREntities(5).map { entity in
                let intent = TimelineConfigurationIntent()
                intent.qrcode = .init(
                    identifier: entity.objectID.uriRepresentation().absoluteString,
                    display: entity.title ?? "QR Code")
                return IntentRecommendation(intent: intent, description: Text(entity.title ?? "QR Code"))
            }
        } catch {
            Logger.logView.error("Widget: Unable to generate widget recommendations.")
            return []
        }
    }
}

struct OldArchiveEntry: TimelineEntry {
    let date: Date = Date()
    var model: QRModel? = nil
    var kind: PresentationKind
    
    enum PresentationKind {
        case snapshot, placeholder, timeline
    }
}

struct OldArchiveWidget: Widget {
    let kind: String = "ArchiveWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: TimelineConfigurationIntent.self,
            provider: OldArchiveProvider()) { entry in
            WidgetViews(entry: entry)
        }
#if os(iOS)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryInline, .accessoryCircular])
#elseif os(macOS)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
#elseif os(watchOS)
        .supportedFamilies([.accessoryCircular,.accessoryInline,.accessoryRectangular])
#endif
        .configurationDisplayName("QR Code")
        .description("Select a QR code saved within your QR Pop archive")
    }
}

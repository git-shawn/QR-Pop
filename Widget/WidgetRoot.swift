//
//  Widgets.swift
//  Widget Mac
//
//  Created by Shawn Davis on 4/21/23.
//

import WidgetKit
import SwiftUI
import Intents
import QRCode
import OSLog

struct Provider: IntentTimelineProvider {
    let moc = Persistence.shared.container.viewContext
    
    func placeholder(in context: Context) -> ArchiveEntry {
        ArchiveEntry(kind: .placeholder)
    }
    
    func getSnapshot(for configuration: TimelineConfigurationIntent,
                     in context: Context,
                     completion: @escaping (ArchiveEntry) -> Void) {
        let entry = ArchiveEntry(kind: .snapshot)
        completion(entry)
    }
    
    func getTimeline(for configuration: TimelineConfigurationIntent,
                     in context: Context,
                     completion: @escaping (Timeline<ArchiveEntry>) -> Void) {
        let entries = [ArchiveEntry(model: getModel(from: configuration), kind: .timeline)]
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
              let entity = Persistence.shared.getQrEntityWithURI(entityURI),
              let model = try? QRModel(withEntity: entity)
        else {
            WidgetLog.warning("Unable to create QRModel from TimelineConfigurationIntent.")
            return nil
        }
        return model
    }
    
    var WidgetLog: Logger {
        Logger(subsystem: Constants.bundleIdentifier, category: "widget-timeline")
    }
}

struct ArchiveEntry: TimelineEntry {
    let date: Date = Date()
    var model: QRModel? = nil
    var kind: PresentationKind
    
    enum PresentationKind {
        case snapshot, placeholder, timeline
    }
}

@main
struct QRPop_Widget: Widget {
    let kind: String = "ArchiveWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: TimelineConfigurationIntent.self, provider: Provider()) { entry in
            WidgetViews(entry: entry)
        }
#if os(iOS)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryInline, .accessoryCircular])
#else
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
#endif
        .configurationDisplayName("QR Pop Archive")
        .description("Display a code from your QR Pop Archive.")
    }
}

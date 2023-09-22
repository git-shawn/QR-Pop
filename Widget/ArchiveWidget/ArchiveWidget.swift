//
//  ArchiveWidget.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/21/23.
//

import SwiftUI
import WidgetKit

@available(watchOS 10.0, iOS 17.0, macOS 14.0, *)
struct ArchiveWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: "ArchiveWidget",
            intent: ArchiveTimelineIntent.self,
            provider: ArchivedCodeProvider()) { entry in
                ArchiveWidgetView(entry: entry)
            }
            .configurationDisplayName("QR Code")
            .description("Select a QR code saved within your QR Pop archive")
            .contentMarginsDisabled()
#if os(iOS)
            .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular, .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
#elseif os(macOS)
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
#elseif os(watchOS)
            .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular, .accessoryCorner])
#endif
    }
}

@available(watchOS 10.0, iOS 17.0, macOS 14.0, *)
struct ArchivedCodeProvider: AppIntentTimelineProvider {
    
    var placeholderModel: QRModel {
        let design = DesignModel(eyeShape: .leaf, pixelShape: .roundedPath, eyeColor: Color.white, pupilColor: Color.white, pixelColor: Color.white, backgroundColor: Color(hue: 0.59, saturation: 0.62, brightness: 0.28), errorCorrection: .medium)
        let model = QRModel(title: "Support Our Parks", design: design, content: BuilderModel(text: "https://www.nationalparks.org"))
        return model
    }
    
    /// Recommend the **5** most recently archived QR codes.
    func recommendations() -> [AppIntentRecommendation<ArchiveTimelineIntent>] {
        guard let entities = try? Persistence.shared.getMostRecentQREntities(5) else {
            return []
        }
        
        let recommendations: [AppIntentRecommendation<ArchiveTimelineIntent>] = entities.compactMap({ entity in
            guard let id = entity.id, let title = entity.title else { return nil }
                return AppIntentRecommendation(
                    intent: ArchiveTimelineIntent(code: ArchivedCodeEntity(id: id, title: title)),
                    description: title)
        })
        
        return recommendations
    }
    
    // A placeholder code to show when there is no data available.
    func placeholder(in context: Context) -> ArchivedCodeEntry {
        return ArchivedCodeEntry(date: Date(), model: placeholderModel)
    }
    
    // A code to show when there may be some data available.
    func snapshot(for configuration: ArchiveTimelineIntent, in context: Context) async -> ArchivedCodeEntry {
        guard let entity = try? Persistence.shared.getQREntityWithUUID(configuration.code.id),
              let model = try? QRModel(withEntity: entity)
        else {
            return ArchivedCodeEntry(date: Date(), model: placeholderModel)
        }
        
        return ArchivedCodeEntry(date: Date(), model: model)
    }
    
    // Codes to show when there is certainly data available.
    func timeline(for configuration: ArchiveTimelineIntent, in context: Context) async -> Timeline<ArchivedCodeEntry> {
        guard let entity = try? Persistence.shared.getQREntityWithUUID(configuration.code.id),
              let model = try? QRModel(withEntity: entity)
        else {
            return Timeline(entries: [], policy: .never)
        }
        let entry = ArchivedCodeEntry(date: Date(), model: model)
        let timeline = Timeline(entries: [entry], policy: .never)
        return timeline
    }
}

@available(watchOS 10.0, iOS 17.0, macOS 14.0, *)
struct ArchivedCodeEntry: TimelineEntry {
    var date: Date
    var model: QRModel
}

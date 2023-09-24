//
//  ArchiveWidgetViews.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/21/23.
//

import SwiftUI
import WidgetKit
import QRCode

@available(watchOS 10.0, iOS 17.0, macOS 14.0, *)
struct ArchiveWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: ArchivedCodeEntry
    var launchURL: String {
        "qrpop:///archive/\(entry.model.id?.uuidString ?? "")"
    }
    
    var body: some View {
        ZStack {
            switch family {
            case .systemSmall, .systemLarge:
                SquareArchiveWidgetView(entry: entry)
            case .systemMedium:
                MediumArchiveWidgetView(entry: entry)
            case .systemExtraLarge:
                XLArchiveWidgetView(entry: entry)
            case .accessoryCircular:
                CircularArchiveWidgetView(entry: entry)
            case .accessoryInline:
                InlineArchiveWidgetView(entry: entry)
            case .accessoryRectangular:
                RectangularArchiveWidgetView(entry: entry)
#if os(watchOS)
            case .accessoryCorner:
                CornerArchiveWidgetView(entry: entry)
#endif
            @unknown default:
                Text("Unsupported Size")
                    .foregroundStyle(Color.white)
                    .containerBackground(Color.black, for: .widget)
            }
        }
        .widgetURL(URL(string: launchURL))
    }
}

//MARK: - Square System Widget
/// The square widget appears in the most unique places, including:
///     - The iPad lock screen as a monochrome widget
///     - StandBy mode with a black background
///     - The home screen itself across all devices (except watchOS)
@available(watchOS 10.0, iOS 17.0, macOS 14.0, *)
struct SquareArchiveWidgetView: View {
    @Environment(\.showsWidgetContainerBackground) var showsWidgetContainerBackground
    let entry: ArchivedCodeEntry
    
    var body: some View {
        ZStack {
            if showsWidgetContainerBackground {
                entry.model.transparentImage(for: 1024)?
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .unredacted()
            } else {
                entry.model.monochromeImage(for: 1024, foregroundColor: .white, backgroundColor: .black.opacity(0))?
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .unredacted()
            }
        }
        .containerBackground(
            entry.model.design.backgroundColor,
            for: .widget
        )
    }
}

//MARK: - Medium System Widget
@available(watchOS 10.0, iOS 17.0, macOS 14.0, *)
struct MediumArchiveWidgetView: View {
    @Environment(\.widgetRenderingMode) var renderingMode
    let entry: ArchivedCodeEntry
    
    var body: some View {
        HStack(spacing: 10) {
            entry.model.transparentImage(for: 1024)?
                .resizable()
                .scaledToFit()
                .unredacted()
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    Text(entry.model.title ?? "My QR Code")
                        .font(.headline)
                        .foregroundStyle(entry.model.design.pixelColor)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    Text(entry.model.created?.formatted(date: .abbreviated, time: .omitted) ?? "Sep 12, 2023")
                        .foregroundStyle(entry.model.design.pixelColor.opacity(0.65))
                    Spacer()
                }
                Spacer()
            }
            .background(
                entry.model.content.builder.icon
                    .resizable()
                    .scaledToFill()
                    .foregroundStyle(entry.model.design.pixelColor.opacity(0.025))
                    .rotationEffect(.degrees(-15))
                    .scaleEffect(1.5)
                    .transformEffect(CGAffineTransform(translationX: 30, y: 0))
            )
            Spacer()
        }
        .padding(8)
        .containerBackground(
            entry.model.design.backgroundColor,
            for: .widget
        )
    }
}

//MARK: XL System Widget
@available(watchOS 10.0, iOS 17.0, macOS 14.0, *)
struct XLArchiveWidgetView: View {
    @Environment(\.widgetRenderingMode) var renderingMode
    let entry: ArchivedCodeEntry
    
    var body: some View {
        HStack(spacing: 10) {
            entry.model.transparentImage(for: 1024)?
                .resizable()
                .scaledToFit()
                .unredacted()
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                    Text(entry.model.title ?? "My QR Code")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(entry.model.design.pixelColor)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    Text(entry.model.created?.formatted(date: .abbreviated, time: .omitted) ?? "Sep 12, 2023")
                        .font(.title)
                        .foregroundStyle(entry.model.design.pixelColor.opacity(0.65))
                    Spacer()
                }
                Spacer()
            }
            .background(
                entry.model.content.builder.icon
                    .resizable()
                    .scaledToFill()
                    .foregroundStyle(entry.model.design.pixelColor.opacity(0.025))
                    .rotationEffect(.degrees(-15))
                    .scaleEffect(1.5)
                    .transformEffect(CGAffineTransform(translationX: 50, y: 0))
            )
            Spacer()
        }
        .padding(8)
        .containerBackground(
            entry.model.design.backgroundColor,
            for: .widget
        )
    }
}

//MARK: Inline Accessory Widget
@available(watchOS 10.0, iOS 17.0, macOS 14.0, *)
struct InlineArchiveWidgetView: View {
    let entry: ArchivedCodeEntry
    
    var body: some View {
        Text("\(entry.model.content.builder.icon) \(entry.model.title ?? "My QR Code")")
    }
}

//MARK: Rectangular Accessory Widget
@available(watchOS 10.0, iOS 17.0, macOS 14.0, *)
struct RectangularArchiveWidgetView: View {
    let entry: ArchivedCodeEntry
    @Environment(\.showsWidgetContainerBackground) var showsWidgetContainerBackground
    
    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            entry.model.content.builder.icon
            VStack(alignment: .leading) {
                Text("\(entry.model.title ?? "My QR Code")")
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                Text(entry.model.created?.formatted(date: .abbreviated, time: .omitted) ?? "Sep 12, 2023")
                    .font(.footnote)
                    .opacity(0.75)
            }
            Spacer()
        }
        .foregroundStyle(showsWidgetContainerBackground ? entry.model.design.pixelColor : Color.white)
        .containerBackground(entry.model.design.backgroundColor, for: .widget)
    }
}

//MARK: Circular Accessory Widget
@available(watchOS 10.0, iOS 17.0, macOS 14.0, *)
struct CircularArchiveWidgetView: View {
    @Environment(\.showsWidgetContainerBackground) var showsWidgetContainerBackground
    let entry: ArchivedCodeEntry
    
    var body: some View {
        ZStack {
            if !showsWidgetContainerBackground {
                Circle()
                    .fill(Color.black)
                    .overlay(
                        Image(systemName: "qrcode")
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(1.15)
                            .rotationEffect(.degrees(15))
                            .opacity(0.15)
                            .clipShape(Circle())
                    )
            }
            entry.model.content.builder.icon
                .resizable()
                .scaledToFit()
                .padding(12)
                .foregroundStyle(showsWidgetContainerBackground ? entry.model.design.pixelColor : Color.white)
        }
        .containerBackground(entry.model.design.backgroundColor, for: .widget)
    }
}

#if os(watchOS)
//MARK: Corner Accessory Widget
@available(watchOS 10.0, *)
struct CornerArchiveWidgetView: View {
    let entry: ArchivedCodeEntry
    @Environment(\.showsWidgetContainerBackground) var showsWidgetContainerBackground
    
    var body: some View {
        ViewThatFits {
            Image(systemName: "qrcode")
                .resizable()
                .bold()
                .scaledToFit()
                .padding()
                .foregroundStyle(showsWidgetContainerBackground ? entry.model.design.pixelColor : Color.white)
        }
        .containerBackground(entry.model.design.backgroundColor, for: .widget)
        .widgetLabel(entry.model.title ?? "My QR Code")
    }
}
#endif

//MARK: Preview Providers
#if os(iOS)
@available(iOS 17.0, *)
struct ArchiveWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ArchiveWidgetView(entry: ArchivedCodeEntry(date: Date(), model: QRModel()))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("System Small")
            ArchiveWidgetView(entry: ArchivedCodeEntry(date: Date(), model: QRModel()))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("System Medium")
            ArchiveWidgetView(entry: ArchivedCodeEntry(date: Date(), model: QRModel()))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("System Large")
            ArchiveWidgetView(entry: ArchivedCodeEntry(date: Date(), model: QRModel()))
                .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
                .previewDisplayName("System XL")
            ArchiveWidgetView(entry: ArchivedCodeEntry(date: Date(), model: QRModel()))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("Accessory Inline")
            ArchiveWidgetView(entry: ArchivedCodeEntry(date: Date(), model: QRModel()))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Accessory Circular")
            ArchiveWidgetView(entry: ArchivedCodeEntry(date: Date(), model: QRModel()))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Accessory Rectangular")
        }
    }
}
#elseif os(watchOS)
@available(watchOS 10.0, *)
struct ArchiveWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ArchiveWidgetView(entry: ArchivedCodeEntry(date: Date(), model: QRModel()))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("Accessory Inline")
            ArchiveWidgetView(entry: ArchivedCodeEntry(date: Date(), model: QRModel()))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Accessory Circular")
            ArchiveWidgetView(entry: ArchivedCodeEntry(date: Date(), model: QRModel()))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Accessory Rectangular")
            ArchiveWidgetView(entry: ArchivedCodeEntry(date: Date(), model: QRModel()))
                .previewContext(WidgetPreviewContext(family: .accessoryCorner))
                .previewDisplayName("Accessory Corner")
        }
    }
}
#endif

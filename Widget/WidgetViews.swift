//
//  WidgetViews.swift
//  Widget Mac
//
//  Created by Shawn Davis on 4/21/23.
//

import SwiftUI
import WidgetKit
import QRCode
import OSLog

struct WidgetViews: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        switch widgetFamily {
            
        case .systemSmall, .systemLarge:
            squareWidget
            
        case .systemMedium, .systemExtraLarge:
            rectangularWidget
#if os(iOS) || os(watchOS)
        case .accessoryCircular:
            accessoryCircular
            
        case .accessoryRectangular:
            accessoryRectangular
            
        case .accessoryInline:
            accessoryInline
#endif
#if os(watchOS)
        case .accessoryCorner:
            accessoryCircular
#endif
        @unknown default:
            fatalError("Unsupported widget size requested")
        }
    }
}

// MARK: - Square Widget

extension WidgetViews {
    
    var squareWidget: some View {
        ZStack {
            if entry.kind == .timeline, let model = entry.model {
                Group {
                    model.design.backgroundColor
                    model.image(for: 512)?
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
                .widgetURL(URL(string: "qrpop:///archive/\(model.id?.uuidString ?? "")"))
                
            } else if entry.kind == .snapshot {
                Color("AccentColor")
                Image("PlaceholderCode")
                    .resizable()
                    .scaledToFit()
                    .padding()
                
            } else if entry.kind == .placeholder || entry.model == nil {
                Color("AccentColor")
                Image(systemName: "qrcode")
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.yellow)
                    .rotationEffect(Angle(degrees: 15))
                    .opacity(0.25)
                    .blendMode(.overlay)
                Text("Please select a QR code")
                    .bold()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Rectangular Widget

extension WidgetViews {
    
    var rectangularWidget: some View {
        
        ZStack {
            if entry.kind == .timeline, let model = entry.model {
                ContainerRelativeShape()
#if !os(watchOS)
                    .fill(.ultraThinMaterial)
#endif
                    .background(
                        model.image(for: 16)?
                            .resizable()
                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    )
                    .overlay(
                        Image(systemName: "qrcode")
                            .resizable()
                            .scaledToFill()
                            .rotationEffect(Angle(degrees: 45))
                            .bold()
                            .opacity(0.15)
                            .blendMode(.softLight)
                            .clipped()
                    )
                Group {
                    HStack(alignment: .center, spacing: 0) {
                        model.image(for: 512)?
                            .resizable()
                            .scaledToFit()
                            .padding(10)
                            .background(
                            ContainerRelativeShape()
                                .fill(model.design.backgroundColor)
                                .shadow(color: .black.opacity(0.2), radius: 10)
                            )
                        VStack(alignment: .leading, spacing: 8) {
                            Text(model.title ?? "My QR Code")
                                .lineLimit(3)
                                .foregroundColor(.primary)
                                .bold()
                            Text(model.created ?? Date(), style: .date)
                                .padding(.leading, 1)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading)
                        Spacer()
                    }
                }
                .widgetURL(URL(string: "qrpop:///archive/\(model.id?.uuidString ?? "")"))
                
            } else if entry.kind == .snapshot {
                ContainerRelativeShape()
#if !os(watchOS)
                    .fill(.ultraThinMaterial)
#endif
                    .background(
                        ZStack {
                            Color("AccentColor")
                            Image("PlaceholderCode")
                                .resizable()
                                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        }
                    )
                    .overlay(
                        Image(systemName: "qrcode")
                            .resizable()
                            .scaledToFill()
                            .rotationEffect(Angle(degrees: 45))
                            .bold()
                            .opacity(0.15)
                            .blendMode(.softLight)
                            .clipped()
                    )
                HStack(alignment: .center, spacing: 0) {
                    Image("PlaceholderCode")
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .background(
                        ContainerRelativeShape()
                            .fill(Color("AccentColor"))
                            .shadow(color: .black.opacity(0.2), radius: 10)
                        )
                    VStack(alignment: .leading, spacing: 8) {
                        Text("QR Pop Website")
                            .lineLimit(3)
                            .foregroundColor(.primary)
                            .bold()
                        Text("April 22, 2023")
                            .padding(.leading, 1)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading)
                    Spacer()
                }
                
            } else if entry.kind == .placeholder || entry.model == nil {
                Color("AccentColor")
                Image(systemName: "qrcode")
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.yellow)
                    .rotationEffect(Angle(degrees: 15))
                    .opacity(0.25)
                    .blendMode(.overlay)
                Text("Please select a QR code")
                    .bold()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
    }
}

#if os(iOS) || os(watchOS)

// MARK: - Circular Widget

extension WidgetViews {
    
    var accessoryCircular: some View {
        ZStack(alignment: .center) {
            GeometryReader { proxy in
                if let model = entry.model {
                    Image(systemName: "rays")
                        .resizable()
                        .scaledToFit()
#if os(iOS)
                        .foregroundStyle(.regularMaterial)
#else
                        .foregroundStyle(.primary.opacity(0.25))
#endif
                        .overlay(
                            model.content.builder.icon
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .frame(maxWidth: proxy.size.width * 0.3)
                                .widgetAccentable()
                        )
                        .widgetURL(URL(string: "qrpop:///archive/\(model.id?.uuidString ?? "")"))
                    
                } else {
                    
                    Image(systemName: "rays")
                        .resizable()
                        .scaledToFit()
#if os(iOS)
                        .foregroundStyle(.regularMaterial)
#else
                        .foregroundStyle(.primary.opacity(0.25))
#endif
                        .overlay(
                            Image(systemName: "qrcode")
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .frame(maxWidth: proxy.size.width * 0.3)
                                .widgetAccentable(true)
                        )
                }
            }
        }
    }
}

// MARK: - Accessory Rectangular

extension WidgetViews {
    
    var accessoryRectangular: some View {
        HStack(alignment: .center, spacing: 10) {
            if let model = entry.model {
                Group {
                    model.content.builder.icon
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 24)
                        .widgetAccentable()
                    VStack(alignment: .leading) {
                        Text(model.title ?? "QR Code")
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(2)
                        Text("\(model.content.builder.title)")
                            .foregroundColor(.white)
                            .opacity(0.5)
                            .font(.footnote)
                    }
                }
                .widgetURL(URL(string: "qrpop:///archive/\(model.id?.uuidString ?? "")"))
                
            } else {
                Image(systemName: "qrcode")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 24)
                    .widgetAccentable()
                VStack(alignment: .leading) {
                    Text("QR Code")
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Text("Select a saved code")
                        .foregroundColor(.white)
                        .opacity(0.5)
                        .font(.footnote)
                }
            }
            Spacer()
        }
    }
}

// MARK: - Accessory Inline

extension WidgetViews {
    
    var accessoryInline: some View {
        Group {
            if let model = entry.model {
                Label(title: {
                    Text(model.title ?? "QR Code")
                }, icon: {
                    model.content.builder.icon
                })
                .widgetAccentable()
                .widgetURL(URL(string: "qrpop:///archive/\(model.id?.uuidString ?? "")"))
                
            } else {
                Label("QR Code", systemImage: "qrcode")
                    .lineLimit(1)
                    .widgetAccentable()
            }
        }
    }
}

#endif

/**
 These previews do not seem to work on any target.
 */
struct WidgetViews_Previews: PreviewProvider {
    static var previews: some View {
#if !os(watchOS)
        WidgetViews(entry: ArchiveEntry(kind: .snapshot))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        WidgetViews(entry: ArchiveEntry(kind: .snapshot))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
#else
        WidgetViews(entry: ArchiveEntry(kind: .snapshot))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
#endif
    }
}

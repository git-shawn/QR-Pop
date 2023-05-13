//
//  RegionBasedActivity.swift
//  Widget iOS
//
//  Created by Shawn Davis on 5/12/23.
//

#if os(iOS)

import SwiftUI
import WidgetKit
import ActivityKit
import QRCode
import OSLog

struct RegionBasedActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RegionBasedActivityAttributes.self, content: { context in
            LiveActivityView(model: context.attributes.model)
        }, dynamicIsland: { context in
            DynamicIsland(expanded: {
                DynamicIslandExpandedRegion(.center, content: {
                    LiveActivityView(model: context.attributes.model, inIsland: true)
                })
            }, compactLeading: {
                Image("qrpop.icon")
                    .foregroundColor(Color("AccentColor"))
                    .padding(.leading, 3)
                    .widgetURL(URL(string: "qrpop:///archive/\(context.attributes.model.id?.uuidString ?? "")"))
            }, compactTrailing: {
                Text("")
            }, minimal: {
                HStack {
                    Spacer()
                    Image("qrpop.icon")
                        .foregroundColor(Color("AccentColor"))
                    Spacer()
                }
                .widgetURL(URL(string: "qrpop:///archive/\(context.attributes.model.id?.uuidString ?? "")"))
            })
        })
    }
}

struct RegionBasedActivityAttributes: ActivityAttributes {
    // The model is static to this activity, but whether or not
    // the user is within the defined region is not and may change.
    public struct ContentState: Codable, Hashable {
        var inRegion: Bool
    }
    
    var model: QRModel
}

struct LiveActivityView: View {
    let model: QRModel
    var inIsland: Bool = false
    
    var body: some View {
        HStack(spacing: inIsland ? 20 : 10) {
            
            if inIsland {
                Spacer()
            }
            
            QRCodeView(qrcode: .constant(model))
                .padding(inIsland ? 0 : 14)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(model.title ?? "My QR Code")
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .font(.headline)
                Group {
                    Text("\(model.content.builder.title) QR Code")
                    Text(model.created ?? Date(), style: .date)
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .frame(minHeight: inIsland ? 0 : 150, maxHeight: .infinity)
        .background(
            Image(systemName: "qrcode")
                .resizable()
                .scaledToFill()
                .rotationEffect(Angle(degrees: 45))
                .bold()
                .opacity(inIsland ? 0 : 0.035)
                .clipped()
        )
        .widgetURL(URL(string: "qrpop:///archive/\(model.id?.uuidString ?? "")"))
    }
    
    
}

#if DEBUG
@available(iOSApplicationExtension 16.2, *)
struct RegionBasedActivity_Previews: PreviewProvider {
    static let demoModel: QRModel = .init(
        title: Constants.loremIpsum,
        created: Date(),
        design: DesignModel(eyeShape: .circle, pixelShape: .curvedPixel, eyeColor: .black, pupilColor: .black, pixelColor: .black, backgroundColor: Color.random, errorCorrection: .low),
        content: BuilderModel(text: Constants.loremIpsum),
        id: UUID())
    
    static let activityAttributes = RegionBasedActivityAttributes(model: demoModel)
    static let activityState = RegionBasedActivityAttributes.ContentState(inRegion: true)
    
    static var previews: some View {
        activityAttributes
            .previewContext(activityState, viewKind: .content)
            .previewDisplayName("Notification")
        
        activityAttributes
            .previewContext(activityState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Compact")
        
        activityAttributes
            .previewContext(activityState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Expanded")
        
        activityAttributes
            .previewContext(activityState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
    }
}
#endif

#endif

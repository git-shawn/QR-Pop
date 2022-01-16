//
//  Widget.swift
//  Widget
//
//  Created by Shawn Davis on 1/16/22.
//

import WidgetKit
import SwiftUI
import UIKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        let entry = WidgetEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let timeline = Timeline(entries: [WidgetEntry(date: Date())], policy: .never)
        completion(timeline)
    }
}

struct WidgetEntry: TimelineEntry {
    let date: Date
}

struct WidgetEntryView : View {
    @AppStorage("widgetImg", store: UserDefaults(suiteName: "group.shwndvs.qr-pop")) var widgetImg: Data = (UIImage(named: "PlaceholderCode")?.pngData()!)!
    
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color(uiColor: UIImage(data: widgetImg)!.averageColor ?? .clear)
            Image(uiImage: UIImage(data: widgetImg)!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(10)
        }
    }
}

@main
struct QRPopWidget: Widget {
    let kind: String = "Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemLarge])
        .configurationDisplayName("QR Code")
        .description("Display a QR code built with QR Pop.")
    }
}

struct QRPopWidget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetEntryView(entry: WidgetEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

extension UIImage {
    
    /// Find the border color of an image, based on this tutorial by Brandon Baars
    /// https://medium.com/swlh/swiftui-read-the-average-color-of-an-image-c736adb43000
    var averageColor: UIColor? {
        // Convert the image to a CIImage
        guard let inputImage = CIImage(image: self) else { return nil }
        
        // We're only considering the color of the top left most pixel.
        let extentVector = CIVector(x: 0, y: 0, z: 1, w: 1)
        
        // Create CIFilter to find average color
        guard let filter = CIFilter(name: "CIAreaAverage",
                                  parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        // Render our color into a 1x1 image, measuring the colors in a bitmap
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)
        
        // Convert the bitmap to a UIColor
        return UIColor(red: CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255,
                       alpha: CGFloat(bitmap[3]) / 255)
    }
}

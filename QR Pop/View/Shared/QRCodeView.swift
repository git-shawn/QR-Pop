//
//  QRCodeView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI
import QRCode
import OSLog


struct QRCodeView: View, Equatable {
    @Binding var design: DesignModel
    @Binding var builder: BuilderModel
    @State private var size: CGFloat = 0
#if !CLOUDEXT
    @EnvironmentObject var sceneModel: SceneModel
#endif
    @State private var isTargetedForDrop: Bool = false
    
    let interactivity: Interactivity
    
    init(design: Binding<DesignModel>, builder: Binding<BuilderModel>, interactivity: Interactivity = .view) {
        self._design = design
        self._builder = builder
        self.interactivity = interactivity
    }
    
    init(qrcode: Binding<QRModel>, interactivity: Interactivity = .view) {
        self._design = qrcode.design
        self._builder = qrcode.content
        self.interactivity = interactivity
    }
    
    static func == (lhs: QRCodeView, rhs: QRCodeView) -> Bool {
        return (lhs.design == rhs.design && lhs.builder.result == rhs.builder.result)
    }
    
    var body: some View {
        switch interactivity {
#if !CLOUDEXT
        case .edit:
            edit
        case .share:
            share
#endif
        case .view:
            code
        }
    }
}

// MARK: - Static QR Code View

extension QRCodeView {
    
    var code: some View {
        
        Canvas { context, size in
            let rectDimension = min(size.width, size.height)
            let rect = CGRect(
                origin: .zero,
                size: CGSize(width: rectDimension, height: rectDimension))
            
            context.drawLayer { context in
                context.scaleBy(x: 0.98, y: 0.98)
                context.translateBy(x: rectDimension*0.01, y: rectDimension*0.01)
                context.fill(.init(roundedRect: rect, cornerRadius: max((rectDimension*0.08),5), style: .continuous), with: .color(design.backgroundColor))
            }
            
            
            if let baseShape = QRCodeShape(text: builder.result, errorCorrection: design.errorCorrection) {
                
                context.drawLayer(content: { context in
                    context.scaleBy(x: 0.9, y: 0.9)
                    context.translateBy(x: rectDimension*0.05, y: rectDimension*0.05)
                    
                    if let offPixelShape = design.offPixels {
                        context.fill(
                            baseShape
                                .components(.offPixels)
                                .offPixelShape(offPixelShape.generator)
                                .logoTemplate(design.getLogoTemplate())
                                .path(in: rect),
                            with: .color(design.pixelColor.opacity(0.2)),
                            style: .init(eoFill: true, antialiased: false)
                        )
                    }
                    
                    context.fill(
                        (baseShape
                            .components(.onPixels)
                            .onPixelShape(design.pixelShape.generator)
                            .logoTemplate(design.getLogoTemplate())
                            .path(in: rect)),
                        with: .color(design.pixelColor),
                        style: .init(eoFill: true, antialiased: false))
                    
                    context.fill(
                        (baseShape
                            .components(.eyeOuter)
                            .eyeShape(design.eyeShape.generator)
                            .logoTemplate(design.getLogoTemplate())
                            .path(in: rect)),
                        with: .color(design.eyeColor),
                        style: .init(eoFill: true, antialiased: false))
                    
                    context.fill(
                        (baseShape
                            .components(.eyePupil)
                            .eyeShape(design.eyeShape.generator)
                            .logoTemplate(design.getLogoTemplate())
                            .path(in: rect)),
                        with: .color(design.pupilColor),
                        style: .init(eoFill: true, antialiased: false))
                    
                    if (design.logo != nil) {
                        context.draw(
                            .init(platformImage: PlatformImage(cgImage: design.getLogoTemplate().image)),
                            in: rect)
                    }
                    
                })
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: max((size * 0.084),5), style: .continuous)
                .strokeBorder(lineWidth: max((size * 0.02),1.5), antialiased: true)
                .foregroundColor(design.pixelColor)
        )
#if os(iOS)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: (size * 0.084), style: .continuous))
#elseif os(macOS)
        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: (size * 0.084), style: .continuous))
#endif
        .aspectRatio(1, contentMode: .fit)
        .readSize() { size in
            self.size = min(size.width,size.height)
        }
    }
}

#if !CLOUDEXT

// MARK: - Image Context Menu

extension QRCodeView {
    
    var share: some View {
        code
            .contextMenu {
                ShareLink(item: QRModel(design: design, content: builder), preview: SharePreview("QR Code", image: QRModel(design: design, content: builder)))
                Menu(content: {
#if os(iOS)
                    ImageButton("Image to Photos", systemImage: "photo") {
                        do {
                            try QRModel(design: design, content: builder).addToPhotoLibrary(for: 512)
                        } catch {
                            Logger.logView.error("QRCodeView: Could not write QR code to photos app.")
                            sceneModel.toaster = .error(note: "Could not save photo")
                        }
                    }
#endif
                    
                    ImageButton("Image\(" to Files", platforms: [.iOS])", systemImage: "folder") {
                        do {
                            let data = try QRModel(design: design, content: builder).pngData(for: 512)
                            sceneModel.exportData(data, type: .png, named: "QR Code")
                        } catch {
                            Logger.logView.error("QRCodeView: Could not create PNG data for QR code.")
                            sceneModel.toaster = .error(note: "Could not save file")
                        }
                    }
                    
                    MenuControlGroupConvertible {
                        ImageButton("PDF\(" to Files", platforms: [.iOS])", image: "pdf", action: {
                            do {
                                let data = try QRModel(design: design, content: builder).pdfData()
                                sceneModel.exportData(data, type: .pdf, named: "QR Code")
                            } catch {
                                Logger.logView.error("ArchiveView: Could not create PDF data for QR code.")
                                sceneModel.toaster = .error(note: "Could not save file")
                            }
                        })
                        
                        ImageButton("SVG\(" to Files", platforms: [.iOS])", image: "svg", action: {
                            do {
                                let data = try QRModel(design: design, content: builder).svgData()
                                sceneModel.exportData(data, type: .svg, named: "QR Code")
                            } catch {
                                Logger.logView.error("ArchiveView: Could not create SVG data for QR code.")
                                sceneModel.toaster = .error(note: "Could not save file")
                            }
                        })
                    }
                }, label: {
                    Label("Save...", systemImage: "square.and.arrow.down")
                })
                
                ImageButton("Copy Image", systemImage: "doc.on.clipboard", action: {
                    QRModel(design: design, content: builder).addToPasteboard(for: 512)
                    sceneModel.toaster = .copied(note: "Image copied")
                })
                
                Divider()
                
                ImageButton("Test Scannability", systemImage: "rectangle.and.text.magnifyingglass", action: {
                    if QRModel(design: design, content: builder).testScannability() {
                        sceneModel.toaster = .success(note: "Can be scanned")
                    } else {
                        sceneModel.toaster = .error(note: "Cannot be scanned")
                    }
                })
            }
            .draggable(QRModel(design: design, content: builder), preview: {
                QRModel(design: design, content: builder).image(for: 256)?
                    .resizable()
                    .scaledToFit()
            })
    }
}

// MARK: - Drop Destination

extension QRCodeView {
    
    var edit: some View {
        
        share
            .brightness(isTargetedForDrop ? 0.3 : 0)
            .dropDestination(for: Data.self, action: { items, point in
                guard let item = items.first,
                      let image = PlatformImage(data: item)
                else { return false }
                
                /// Logo overlays cannot contain a QR code, that would confuse the scanner.
                /// Checking for a QR code also prevents the user from accidentally dropping *this* view.
                if image.containsQRCode {
                    return false
                } else {
                    do {
                        Logger.logView.debug("QRCodeView: Attempting Drop")
                        try design.setLogo(item)
                        return true
                    } catch {
                        Logger.logView.notice("QRCodeView: A valid image could not be added to the model via dropDestination().")
                        return false
                    }
                }
            }, isTargeted: {
                isTargetedForDrop = $0
            })
    }
}

#endif

// MARK: - Interactivity Level

extension QRCodeView {
    
    /// The level of interactivity to apply to the view.
    ///
    /// The view can be initiated at one of three tiers of interactivity:
    /// - `view`:  The view can be seen but not interacted with.
    /// - `share`: The view can be interacted with via its context menu and `draggable`.
    /// - `edit`: The view can be interactd with via its context menu and modified as a `dropDestination`.
    enum Interactivity {
        case view
        
#if !CLOUDEXT
        case share
        case edit
#endif
    }
}

#if targetEnvironment(simulator)
struct QRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeView(qrcode: .constant(QRModel()), interactivity: .view)
            .previewDisplayName("Simple Code")
        QRCodeView(qrcode: .constant(QRModel(design: DesignModel(eyeShape: .shield, pixelShape: .insetRound, eyeColor: .indigo, pupilColor: .indigo, pixelColor: .indigo, backgroundColor: .mint, offPixels: nil, errorCorrection: .high, logoPlacement: .center, logo: nil), content: BuilderModel(text: "Lorem ipsum"))), interactivity: .view)
            .previewDisplayName("Complex Code")
        QRCodeView(qrcode: .constant(QRModel(design: DesignModel(eyeShape: .shield, pixelShape: .insetRound, eyeColor: .indigo, pupilColor: .indigo, pixelColor: .indigo, backgroundColor: .mint, offPixels: nil, errorCorrection: .high, logoPlacement: .center, logo: nil), content: BuilderModel(text: "Lorem ipsum"))), interactivity: .view)
            .frame(width: 100, height: 100)
            .previewDisplayName("Tiny Code")
        QRCodeTechncialPreview()
            .previewDisplayName("Technical Preview")
    }
}

struct QRCodeTechncialPreview: View {
    let design = DesignModel()
    let builder = BuilderModel(text: "Preserve unimpaired the natural and cultural resources and values of the National Park System for the enjoyment, education, and inspiration of this and future generations")
    
    var body: some View {
        Canvas { context, size in
            let rectDimension = min(size.width, size.height)
            let rect = CGRect(
                origin: .zero,
                size: CGSize(width: rectDimension, height: rectDimension))
            
            if let baseShape = QRCodeShape(text: builder.result, errorCorrection: design.errorCorrection) {
                
                context.drawLayer(content: { context in
                    context.scaleBy(x: 0.9, y: 0.9)
                    context.translateBy(x: rectDimension*0.05, y: rectDimension*0.05)
                    
                    context.stroke(
                        (baseShape
                            .components(.offPixels)
                            .eyeShape(design.eyeShape.generator)
                            .logoTemplate(design.getLogoTemplate())
                            .path(in: rect)),
                        with: .color(.red),
                        lineWidth: 1)
                    
                    context.stroke(
                        (baseShape
                            .components(.onPixels)
                            .onPixelShape(design.pixelShape.generator)
                            .logoTemplate(design.getLogoTemplate())
                            .path(in: rect)),
                        with: .color(.blue),
                        lineWidth: 1)
                    
                    context.fill(
                        (baseShape
                            .components(.onPixels)
                            .onPixelShape(design.pixelShape.generator)
                            .logoTemplate(design.getLogoTemplate())
                            .path(in: rect)),
                        with: .color(.blue.opacity(0.2)))
                    
                    context.stroke(
                        (baseShape
                            .components(.eyeOuter)
                            .eyeShape(design.eyeShape.generator)
                            .logoTemplate(design.getLogoTemplate())
                            .path(in: rect)),
                        with: .color(.orange),
                        lineWidth: 1)
                    
                    context.fill(
                        (baseShape
                            .components(.eyeOuter)
                            .eyeShape(design.eyeShape.generator)
                            .logoTemplate(design.getLogoTemplate())
                            .path(in: rect)),
                        with: .color(.orange.opacity(0.2)))
                    
                    context.stroke(
                        (baseShape
                            .components(.eyePupil)
                            .eyeShape(design.eyeShape.generator)
                            .logoTemplate(design.getLogoTemplate())
                            .path(in: rect)),
                        with: .color(.green),
                        lineWidth: 1)
                    
                    context.fill(
                        (baseShape
                            .components(.eyePupil)
                            .eyeShape(design.eyeShape.generator)
                            .logoTemplate(design.getLogoTemplate())
                            .path(in: rect)),
                        with: .color(.green.opacity(0.2)))
                    
                })
            }
        }
        .drawingGroup()
    }
}

#endif

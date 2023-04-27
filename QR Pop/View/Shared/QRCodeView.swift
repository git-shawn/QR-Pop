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
#if !CLOUDEXT
    @EnvironmentObject var sceneModel: SceneModel
#endif
    @State private var isTargetedForDrop: Bool = false
    var logoImage: Image? {
        return design.resolvingLogo()
    }
    
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
        GeometryReader { geo in
            let cornerRadius = (geo.size.width * 0.08)
            let baseShape = QRCodeShape(text: builder.result, errorCorrection: design.errorCorrection)
            
            ZStack(alignment: design.logoPlacement == .center ? .center : .bottomTrailing) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(design.backgroundColor)
                    .padding(geo.size.width*0.01)
                
                Group {
                    if let offPixelShape = design.offPixels {
                        baseShape?
                            .components(.offPixels)
                            .offPixelShape(offPixelShape.generator)
                            .logoTemplate(design.getLogoTemplate())
                            .fill(design.pixelColor.opacity(0.3))
                    }
                    
                    baseShape?
                        .components(.onPixels)
                        .onPixelShape(design.pixelShape.generator)
                        .logoTemplate(design.getLogoTemplate())
                        .fill(design.pixelColor)
                    
                    baseShape?
                        .components(.eyeOuter)
                        .eyeShape(design.eyeShape.generator)
                        .fill(design.eyeColor)
                    
                    baseShape?
                        .components(.eyePupil)
                        .eyeShape(design.eyeShape.generator)
                        .fill(design.pupilColor)
                    
                    logoImage?
                        .resizable()
                        .scaledToFit()
                }
                .padding(min(geo.size.width, geo.size.height)*0.05)
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(design.pixelColor, lineWidth: (geo.size.width * 0.02))
            }
            .mask {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            }
            .aspectRatio(1, contentMode: .fit)
            .animation(.default, value: design)
            .contentShape(.dragPreview, RoundedRectangle(cornerRadius: cornerRadius))
#if os(iOS)
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: cornerRadius))
#endif
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#if !CLOUDEXT

// MARK: - Image Context Menu

extension QRCodeView {
    
    var share: some View {
        code
            .contextMenu {
                ShareLink(item: QRModel(design: design, content: builder), preview: SharePreview("QR Code", image: QRModel(design: design, content: builder)))
                
#if os(iOS)
                ImageButton("Save to Photos", systemImage: "square.and.arrow.down", action: {
                    do {
                        try QRModel(design: design, content: builder).addToPhotoLibrary(for: 512)
                    } catch let error {
                        debugPrint(error)
                        sceneModel.toaster = .error(note: "Could not save photo")
                    }
                })
#endif
                
                ImageButton("Save to Files", systemImage: "plus.rectangle.on.folder", action: {
                    do {
                        let data = try QRModel(design: design, content: builder).pngData(for: 512)
                        sceneModel.exportData(data, type: .png, named: "QR Code")
                    } catch let error {
                        debugPrint(error)
                        sceneModel.toaster = .error(note: "Could not save file")
                    }
                })
                
                ImageButton("Add to Pasteboard", systemImage: "doc.on.clipboard", action: {
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

struct QRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeView(qrcode: .constant(QRModel()), interactivity: .view)
    }
}

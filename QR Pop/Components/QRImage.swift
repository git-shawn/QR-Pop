//
//  QRImage.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI
import UniformTypeIdentifiers
import AlertToast

struct QRImage: View {
    @Binding var qrCode: Data
    @Binding var bg: Color
    @Binding var fg: Color
    @State var showShare: Bool = false
    @State private var didSave: Bool = false
    @State private var didCopy: Bool = false
    private let imageSaver = ImageSaver()
    #if os(macOS)
    @State private var showPicker = false
    #else
    @State private var brightness: CGFloat = 0.5
    @State private var brightnessToggle: Bool = false
    #endif

    
    var body: some View {
        qrCode.swiftImage!
            .resizable()
            .padding(10)
        #if os(macOS)
            .frame(maxWidth: 300, maxHeight: 300)
        #else
            .frame(maxWidth: 400, maxHeight: 400)
        #endif
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .foregroundColor(bg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(fg, lineWidth: 3)
            )
            .accessibilityLabel("QR Code Image")
            .onDrag({
                #if os(iOS)
                let provider = NSItemProvider(object: qrCode.image as UIImage)
                #else
                let provider = NSItemProvider(item: qrCode as NSSecureCoding, typeIdentifier: UTType.png.identifier)
                #endif
                return provider
            })
            .contextMenu(menuItems: {
                #if os(iOS)
                Button(action: {
                    if (!brightnessToggle) {
                        UIScreen.main.brightness = 1
                    } else {
                        UIScreen.main.brightness = brightness
                    }
                    brightnessToggle.toggle()
                }) {
                    if (!brightnessToggle) {
                        Label("Increase Brightness", systemImage: "lightbulb")
                    } else {
                        Label("Decrease Brightness", systemImage: "lightbulb.slash")
                    }
                }
                Divider()
                #endif
                Button(action: {
                    Clipboard.writeImage(imageData: qrCode)
                    didCopy = true
                }) {
                    Label("Copy Image", systemImage: "photo.on.rectangle")
                }
                #if os(macOS)
                Divider()
                #endif
                Button(action: {
                    imageSaver.successHandler = {
                        didSave = true
                    }
                    imageSaver.save(imageData: qrCode)
                }) {
                    Label("Save Image", systemImage: "square.and.arrow.down")
                }
                Button(action: {
                    #if os(iOS)
                    showShareSheet(with: [qrCode.image])
                    #else
                    showPicker = true
                    #endif
                }) {
                    Label("Share Image", systemImage: "square.and.arrow.up")
                }
                #if os(macOS)
                Divider()
                Button(action: {
                    let printView = NSImageView(frame: NSRect(x: 0, y: 0, width: 300, height: 300))
                    printView.image = qrCode.image
                    let printOperation = NSPrintOperation(view: printView)
                    printOperation.printInfo.scalingFactor = 1
                    printOperation.printInfo.isVerticallyCentered = true
                    printOperation.printInfo.isHorizontallyCentered = true
                    printOperation.runModal(for: NSApplication.shared.windows.first!, delegate: self, didRun: nil, contextInfo: nil)
                }) {
                    Label("Print Image", systemImage: "")
                }
                #endif
            })
            .toast(isPresenting: $didSave, duration: 2, tapToDismiss: true) {
                AlertToast(displayMode: .alert, type: .systemImage("checkmark", .accentColor), title: "Image Saved")
            }
            .toast(isPresenting: $didCopy, duration: 2, tapToDismiss: true) {
                AlertToast(displayMode: .alert, type: .systemImage("photo.on.rectangle", .accentColor), title: "Image Copied")
            }
            #if os(macOS)
            .background(SharingsPicker(isPresented: $showPicker, sharingItems: [qrCode.image]))
            #else
            .onAppear(perform: {
                brightness = UIScreen.main.brightness
            })
            .onDisappear(perform: {
                UIScreen.main.brightness = brightness
            })
            #endif
    }
}

#if os(macOS)
extension Data {
    /// Returns the data as a SwiftUI image.
    /// - Warning: Unsafely translates the data. Be confident this is an image.
    var swiftImage: Image? { Image(nsImage: NSImage(data: self)!) }
    
    /// Returns the data as an NSImage or UIImage, depending on the platform.
    /// - Warning: Unsafely translates the data. Be confident this is an image.
    var image: NSImage { NSImage(data: self)! }
}
#else
extension Data {
    /// Returns the data as a SwiftUI image.
    /// - Warning: Unsafely translates the data. Be confident this is an image.
    var swiftImage: Image? { Image(uiImage: UIImage(data: self)!) }
    
    /// Returns the data as an NSImage or UIImage, depending on the platform.
    /// - Warning - Unsafely translates the data. Be confident this is an image.
    var image: UIImage { UIImage(data: self)! }
}
#endif

struct QRImage_Previews: PreviewProvider {
    @State static var bg: Color = .white
    @State static var fg: Color = .black
    @State static var qrImage: Data = QRCode().generate(content: "", fg: fg, bg: bg)
    static var previews: some View {
        QRImage(qrCode: $qrImage, bg: $bg, fg: $fg)
    }
}

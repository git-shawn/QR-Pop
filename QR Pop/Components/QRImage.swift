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
    @EnvironmentObject var qrCode: QRCode
    
    @State var showShare: Bool = false
    @State private var didSave: Bool = false
    @State private var didCopy: Bool = false
    @State private var showData: Bool = false
    @State private var isDropping: Bool = false
    private let imageSaver = ImageSaver()
    
    #if os(macOS)
    @State private var showPicker = false
    #endif

    
    var body: some View {
        qrCode.imgData.swiftImage!
            .resizable()
            .padding(10)
        #if os(macOS)
            .frame(maxWidth: 350, maxHeight: 350)
            .blur(radius: (isDropping ? 6 : 0))
        #else
            .frame(maxWidth: 400, maxHeight: 400)
        #endif
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .foregroundColor(qrCode.backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(qrCode.foregroundColor, lineWidth: 3)
            )
            .accessibilityLabel("QR Code Image")
            .onDrag({
                #if os(iOS)
                let provider = NSItemProvider(object: qrCode.imgData.image as UIImage)
                #else
                let provider = NSItemProvider(item: qrCode.imgData as NSSecureCoding, typeIdentifier: UTType.png.identifier)
                #endif
                return provider
            })
        #if os(macOS)
            .onDrop(of: ["public.file-url"], isTargeted: $isDropping, perform: {providers -> Bool in
                providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                    if let data = data, let path = NSString(data: data, encoding: 4), let url = URL(string: path as String) {
                        let image = NSImage(contentsOf: url)
                        DispatchQueue.main.async {
                            qrCode.overlayImage = image?.png
                            qrCode.generate()
                        }
                    }
                })
                return true
            })
        #endif
            .contextMenu(menuItems: {
                Button(action: {
                    Clipboard.writeImage(imageData: qrCode.imgData)
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
                    imageSaver.save(imageData: qrCode.imgData)
                }) {
                    Label("Save Image", systemImage: "square.and.arrow.down")
                }
                Button(action: {
                    #if os(iOS)
                    showShareSheet(with: [qrCode.imgData.image])
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
                    printView.image = qrCode.imgData.image
                    let printOperation = NSPrintOperation(view: printView)
                    printOperation.printInfo.scalingFactor = 1
                    printOperation.printInfo.isVerticallyCentered = true
                    printOperation.printInfo.isHorizontallyCentered = true
                    printOperation.runModal(for: NSApplication.shared.windows.first!, delegate: self, didRun: nil, contextInfo: nil)
                }) {
                    Label("Print Image", systemImage: "")
                }
                #endif
                Divider()
                Button(action: {
                    showData.toggle()
                }) {
                    Label("View Encoded Data", systemImage: "rectangle.and.text.magnifyingglass")
                }
            })
            .toast(isPresenting: $didSave, duration: 2, tapToDismiss: true) {
                AlertToast(displayMode: .alert, type: .systemImage("checkmark", .accentColor), title: "Image Saved")
            }
            .toast(isPresenting: $didCopy, duration: 2, tapToDismiss: true) {
                AlertToast(displayMode: .alert, type: .systemImage("photo.on.rectangle", .accentColor), title: "Image Copied")
            }
            .sheet(isPresented: $showData, content: {
                ModalNavbar(navigationTitle: "Data", showModal: $showData) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Encoded Raw Data")
                                    .font(.largeTitle)
                                    .bold()
                                Spacer()
                            }
                            Text("\(qrCode.codeContent)")
                            Spacer()
                        }.padding()
                    }
                }
            })
            #if os(macOS)
            .background(SharingsPicker(isPresented: $showPicker, sharingItems: [qrCode.imgData.image]))
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

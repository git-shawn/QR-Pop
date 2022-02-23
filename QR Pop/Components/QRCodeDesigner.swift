//
//  QRCodeDesigner.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/18/21.
//
import SwiftUI
#if os(macOS)
import UniformTypeIdentifiers
#endif

/// A panel of design elements to customize a QR code
struct QRCodeDesigner: View {
    @EnvironmentObject var qrCode: QRCode
    
    @State var showOverlayPicker: Bool = false
    @State private var warningVisible: Bool = false
    @State private var showPicker: Bool = false
    @State private var showDesigner: Bool = false
    
    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text("Code Design")
                    .font(.headline)
                    .padding(.vertical, 10)
                    .padding(.leading)
                Image(systemName: "chevron.up.circle")
                    .foregroundColor(.accentColor)
                    .imageScale(.large)
                    .transition(.move(edge: .leading))
                    .rotationEffect(.degrees(showDesigner ? 180 : 0))
                    .animation(.interpolatingSpring(stiffness: 75, damping: 7, initialVelocity: 6), value: showDesigner)
                    .onTapGesture {
                        withAnimation() {
                            showDesigner.toggle()
                        }
                    }
                Spacer()
                if (!showDesigner && warningVisible) {
                    Image(systemName: "eye.trianglebadge.exclamationmark")
                        .foregroundColor(.accentColor)
                        .imageScale(.large)
                        .padding(.trailing)
                }
            }
            if (showDesigner) {
                VStack {
                    if warningVisible {
                        HStack(alignment: .center, spacing: 15) {
                            Image(systemName: "eye.trianglebadge.exclamationmark")
                                .font(.largeTitle)
                            VStack(alignment: .leading) {
                                Text("The background and foreground colors are too similar.")
                                    .font(.headline)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("This code may not scan. Consider picking colors with more contrast.")
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }.foregroundColor(Color("WarningLabel"))
                        .frame(maxWidth: 350)
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("WarningBkg"))
                                .padding(5)
                        )
                        .animation(.spring(), value: warningVisible)
                        .padding(.top, 5)
                        .padding(.bottom, 15)
                    }
                    VStack(alignment: .center, spacing: 10) {
                        #if os(iOS)
                        ColorPicker("Background color", selection: $qrCode.backgroundColor, supportsOpacity: true)
                        ColorPicker("Foreground color", selection: $qrCode.foregroundColor, supportsOpacity: false)
                        #else
                        HStack() {
                            Text("Background color")
                            Spacer()
                            ColorPicker("Background color", selection: $qrCode.backgroundColor, supportsOpacity: true)
                                .labelsHidden()
                        }.frame(maxWidth: 350)
                        HStack() {
                            Text("Foreground color")
                            Spacer()
                            ColorPicker("Foreground color", selection: $qrCode.foregroundColor, supportsOpacity: false)
                                .labelsHidden()
                        }.frame(maxWidth: 350)
                        #endif
                        
                        HStack(alignment: .firstTextBaseline) {
                            #if os(iOS)
                            Text("Shape Style")
                            Spacer()
                            #endif
                        Picker("Shape Style", selection: $qrCode.pointStyle, content: {
                            Label("Square", systemImage: "square").tag(QRPointStyle.square)
                            Label("Circle", systemImage: "circle").tag(QRPointStyle.circle)
                            Label("Diamond", systemImage: "diamond").tag(QRPointStyle.diamond)
                            Label("Star", systemImage: "star").tag(QRPointStyle.star)
                        })
                        #if os(iOS)
                        .pickerStyle(.menu)
                        .padding(.vertical, 6)
                        .padding(.horizontal)
                        .background(Color("ButtonBkg"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        #else
                        .frame(maxWidth: 350)
                        #endif
                        .padding(.top)
                        .onChange(of: qrCode.pointStyle, perform: {_ in qrCode.generate()})
                        }
                        
                        HStack {
                            #if os(iOS)
                            Button(action: {
                                showPicker = true
                            }) {
                                Label("Add Image", systemImage: "photo")
                                .labelStyle(.titleOnly)
                                .padding(5)
                                .frame(maxWidth: 350)
                            }.popover(isPresented: $showPicker) {
                                ImagePicker(sourceType: .photoLibrary, onImagePicked: {image in
                                    qrCode.overlayImage = image.pngData()!
                                }).ignoresSafeArea()
                            }
                            .buttonStyle(PlainButtonStyle())
                            .foregroundColor(.accentColor)
                            .padding(.vertical, 6)
                            .padding(.horizontal)
                            .background(Color("ButtonBkg"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.vertical, 10)
                            #else
                            Button(action: {
                                let panel = NSOpenPanel()
                                panel.canChooseDirectories = false
                                panel.canChooseFiles = true
                                panel.allowsMultipleSelection = false
                                panel.title = "Pick an Image to Add"
                                panel.allowedContentTypes = [UTType.png, UTType.jpeg]
                                if panel.runModal() == .OK {
                                    let image = NSImage(byReferencing: panel.url!)
                                    qrCode.overlayImage = image.resized(to: NSSize(width: 300, height: CGFloat(ceil(300/image.size.width * image.size.height))))?.png!
                                }
                            }) {
                                Label("Add Image", systemImage: "photo")
                                .labelStyle(.titleOnly)
                            }
                            .buttonStyle(QRPopPlainButton())
                            .padding(.vertical, 10)
                            #endif
                            if (qrCode.overlayImage != nil) {
                                Button(action: {
                                    qrCode.overlayImage = nil
                                    qrCode.generate()
                                }) {
                                    Label("Remove Image", systemImage: "trash")
                                        .foregroundColor(.red)
                                        .labelStyle(.iconOnly)
                                    #if os(macOS)
                                        .imageScale(.large)
                                    #endif
                                }
                                #if os(macOS)
                                    .buttonStyle(PlainButtonStyle())
                                #endif
                                .padding(.leading, 6)
                            }
                        }.animation(.interactiveSpring(), value: qrCode.overlayImage)
                        
                    }.padding(.horizontal, 20)
                    .onChange(of: [qrCode.backgroundColor, qrCode.foregroundColor], perform: {_ in
                        qrCode.generate()
                        evaluateContrast()
                    }).padding(.bottom)
                }.transition(.moveAndFadeToTop)
            }
        }.padding(5)
        .background(.thickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.vertical)
        #if os(macOS)
        .padding(.horizontal, 10)
        .onAppear(perform: {
            evaluateContrast()
        })
        #endif
    }
    
    private func evaluateContrast() {
        let cRatio = qrCode.backgroundColor.contrastRatio(with: qrCode.foregroundColor)
        if cRatio < 2.5 {
            withAnimation {
                warningVisible = true
            }
        } else {
            withAnimation {
                warningVisible = false
            }
        }
    }
}

extension AnyTransition {
    static var moveAndFadeToTop: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity.animation(.easeIn(duration: 0.65))),
            removal: .move(edge: .top).combined(with: .opacity.animation(.easeOut(duration: 0.1)))
        )
    }
    
    static var moveAndFadeToBottom: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity.animation(.easeIn(duration: 0.3))),
            removal: .move(edge: .bottom).combined(with: .opacity.animation(.easeOut(duration: 0.3)))
        )
    }
}

#if os(macOS)
extension NSImage {
    func resized(to newSize: NSSize) -> NSImage? {
        if let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(newSize.width), pixelsHigh: Int(newSize.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) {
            bitmapRep.size = newSize
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
            draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height), from: .zero, operation: .copy, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()

            let resizedImage = NSImage(size: newSize)
            resizedImage.addRepresentation(bitmapRep)
            return resizedImage
        }

        return nil
    }
}
#endif

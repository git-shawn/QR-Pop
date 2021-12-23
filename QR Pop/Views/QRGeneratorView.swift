//
//  QRGeneratorView.swift
//  QR Pop
//
//  Created by Shawn Davis on 12/21/21.
//

import SwiftUI

struct QRGeneratorView: View {
    @StateObject var qrCode = QRCode()
    
    var generatorType: QRGeneratorType
    @State private var presentCode: Bool = false
    
    #if os(macOS)
    @State private var showDesignPopover: Bool = false
    private let toolbarTrailingPlacement: ToolbarItemPlacement = .primaryAction
    #else
    @State private var showHelp: Bool = false
    private let toolbarTrailingPlacement: ToolbarItemPlacement = .navigationBarTrailing
    let initialBrightness: CGFloat = UIScreen.main.brightness
    #endif
    
    //Unique variables for link
    @State private var text: String = ""
    
    var body: some View {
        GeometryReader {geometry in
            ScrollView {
                if (geometry.size.width < 600) {
                    VStack {
                        QRImage()
                            .environmentObject(qrCode)
                            .padding()
                        generatorType.destination
                            .environmentObject(qrCode)
                        #if os(iOS)
                        QRCodeDesigner()
                            .environmentObject(qrCode)
                        #endif
                    }.padding(.horizontal)
                    .frame(width: geometry.size.width)
                } else {
                    HStack(alignment: .center, spacing: 15) {
                        QRImage()
                            .environmentObject(qrCode)
                            .padding()
                            .frame(maxHeight: geometry.size.height)
                        VStack {
                            generatorType.destination
                                .environmentObject(qrCode)
                            #if os(iOS)
                            QRCodeDesigner()
                                .environmentObject(qrCode)
                            #endif
                        }.padding(.trailing)
                    }.frame(width: geometry.size.width)
                }
            }
        }.navigationTitle(generatorType.name)
        .toolbar(content: {
            #if os(macOS)
            ToolbarItem(placement: toolbarTrailingPlacement) {
                Button(
                action: {
                    showDesignPopover.toggle()
                }){
                    Label("Style", systemImage: "paintpalette")
                }.popover(isPresented: $showDesignPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                    QRCodeDesigner()
                        .environmentObject(qrCode)
                        .frame(minWidth: 300)
                }
            }
            #endif
            #if os(macOS)
            ToolbarItem(placement: toolbarTrailingPlacement) {
                SaveButton(qrCode: qrCode.imgData)
            }
            #endif
            ToolbarItem(placement: toolbarTrailingPlacement) {
                ShareButton(shareContent: [qrCode.imgData.image], buttonTitle: "Share")
            }
            ToolbarItem(placement: toolbarTrailingPlacement) {
                Menu {
                    Button(role: .destructive, action: qrCode.reset) {
                        Label("Clear", systemImage: "trash")
                    }
//                    Button(action: qrCode.reset) {
//                        Label("Add to Widget", systemImage: "apps.iphone.badge.plus")
//                    }
//                    Button(action: qrCode.reset) {
//                        Label("Add to Watch", systemImage: "applewatch")
//                    }
//                    Divider()
//                    Button(action: qrCode.reset) {
//                        Label("Save as SVG", systemImage: "arrow.down.doc")
//                    }
//                    Divider()
                    #if os(iOS)
                    Button(action: {showHelp = true}) {
                        Label("Help", systemImage: "questionmark")
                    }
                    #else
                    Button(action: {
                        let printView = NSImageView(frame: NSRect(x: 0, y: 0, width: 300, height: 300))
                        printView.image = qrCode.imgData.image
                        let printOperation = NSPrintOperation(view: printView)
                        printOperation.printInfo.scalingFactor = 1
                        printOperation.printInfo.isVerticallyCentered = true
                        printOperation.printInfo.isHorizontallyCentered = true
                        printOperation.runModal(for: NSApplication.shared.windows.first!, delegate: self, didRun: nil, contextInfo: nil)
                    }) {
                        Label("Print Code", systemImage: "printer")
                    }
                    #endif
                    Button(action: {presentCode = true}) {
                        Label("Present Code", systemImage: "arrow.up.left.and.arrow.down.right")
                    }
                } label: {
                    Label("More...", systemImage: "ellipsis.circle")
                }
            }
        })
        #if os(iOS)
        .alert(isPresented: $showHelp) {
            Alert(title: Text("\(generatorType.name) Generator"), message: Text(generatorType.description), dismissButton: .default(Text("Close")))
        }
        #else
        .touchBar() {
            HStack {
                Button(role: .destructive, action: qrCode.reset) {
                    Label("Clear All", systemImage: "trash")
                }.foregroundColor(.red)
                Button(action: {presentCode = true}) {
                    Label("Present Code", systemImage: "arrow.up.left.and.arrow.down.right")
                }
            }
        }
        #endif
        .sheet(isPresented: $presentCode) {
            GeometryReader { geometry in
                VStack(alignment: .center) {
                    Spacer()
                        qrCode.imgData.swiftImage!
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(16)
                        #if os(iOS)
                            .frame(maxWidth: geometry.size.width-20, maxHeight: geometry.size.height-20, alignment: .center)
                            .shadow(color: Color(.displayP3, red: 0, green: 0, blue: 0, opacity: 0.1), radius: 16, x: 10, y: 10)
                            .padding(10)
                        #else
                            .frame(width: 650, height: 650, alignment: .center)
                            .shadow(color: Color(.displayP3, red: 0, green: 0, blue: 0, opacity: 0.1), radius: 16, x: 0, y: 10)
                            .onTapGesture {
                                presentCode = false
                            }
                        #endif
                    Spacer()
                }
                #if os(iOS)
                .frame(width: geometry.size.width)
                #else
                .frame(width: 700, height: 700)
                #endif
            }
            #if os(iOS)
            .background(BackgroundClearView())
                .ignoresSafeArea()
            .onAppear(perform: {
                UIScreen.main.brightness = CGFloat(1)
            })
            .onDisappear(perform: {
                UIScreen.main.brightness = initialBrightness
            })
            #else
            .frame(width: 700, height: 700)
            .touchBar() {
                Button(action: {presentCode = false}) {
                    Label("Dimiss Code", systemImage: "arrow.down.right.and.arrow.up.left")
                }
            }
            #endif
        }
    }
}

#if os(iOS)
struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        view.applyBlurEffect()
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

extension UIView {
    func applyBlurEffect() {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
}
#endif

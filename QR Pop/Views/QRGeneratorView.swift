//
//  QRGeneratorView.swift
//  QR Pop
//
//  Created by Shawn Davis on 12/21/21.
//

import SwiftUI
import CoreSpotlight
#if os(iOS)
import Intents
import EFQRCode
#endif

struct QRGeneratorView: View {
    @StateObject var qrCode = QRCode()
    
    var generatorType: QRGeneratorType
    @State private var presentCode: Bool = false
    
    #if os(macOS)
    private let toolbarTrailingPlacement: ToolbarItemPlacement = .primaryAction
    #else
    private let toolbarTrailingPlacement: ToolbarItemPlacement = .navigationBarTrailing
    let initialBrightness: CGFloat = UIScreen.main.brightness
    #endif
    
    var body: some View {
        GeometryReader {geometry in
            if (geometry.size.width < 600) {
            ScrollView {
                    VStack {
                        QRImage()
                            .environmentObject(qrCode)
                            .padding()
                        generatorType.destination
                            .environmentObject(qrCode)
                        QRCodeDesigner()
                            .environmentObject(qrCode)
                    }.padding(.horizontal)
                    .frame(width: geometry.size.width)
                }
            }  else {
                HStack(alignment: .top, spacing: 15) {
                    VStack {
                        QRImage()
                            .environmentObject(qrCode)
                            .padding()
                        Spacer()
                    }.frame(maxHeight: geometry.size.height)
                    ScrollView {
                        #if os(macOS)
                        Spacer()
                        #endif
                        VStack {
                            generatorType.destination
                                .environmentObject(qrCode)
                            QRCodeDesigner()
                                .environmentObject(qrCode)
                        }
                        #if os(iOS)
                        .padding(.vertical, 10)
                        #else
                        .padding(.vertical)
                        #endif
                    }.padding(.trailing)
                }.frame(width: geometry.size.width)
            }
        }.navigationTitle(generatorType.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #else
        .frame(minWidth: 300)
        #endif
        .onAppear(perform: {
            qrCode.generatorSource = generatorType
        })
        .toolbar(content: {
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
                    #if os(iOS)
                    Text("\(generatorType.description)")
                    Divider()
                    #endif
                    Button(role: .destructive, action: qrCode.reset) {
                        Label("Clear", systemImage: "trash")
                    }
                    #if os(macOS)
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
        .userActivity("shwndvs.QR-Pop.generator-selection") { activity in
            #if os(iOS)
            activity.isEligibleForSearch = true
            
            let attributes = CSSearchableItemAttributeSet(contentType: UTType.item)
            attributes.contentDescription = "Generate a QR Code"
            activity.contentAttributeSet = attributes
            #endif
            
            activity.isEligibleForHandoff = true
            activity.title = "\(generatorType.name) Generator"
            activity.userInfo = ["genId": generatorType.id]
            activity.becomeCurrent()
        }
        #if os(macOS)
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
                            .shadow(color: qrCode.foregroundColor.opacity(0.2), radius: 20, x: 0, y: 10)
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

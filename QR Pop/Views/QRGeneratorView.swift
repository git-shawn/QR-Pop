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
    
    #if os(macOS)
    private let toolbarTrailingPlacement: ToolbarItemPlacement = .primaryAction
    #else
    private let toolbarTrailingPlacement: ToolbarItemPlacement = .navigationBarTrailing
    
    let initialBrightness: CGFloat = UIScreen.main.brightness
    @EnvironmentObject var externalDisplayContent: ExternalDisplayContent
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
                } label: {
                    Label("More...", systemImage: "ellipsis.circle")
                }
            }
        })
        .userActivity("shwndvs.QR-Pop.generator-selection") { activity in
            #if os(iOS)
            activity.isEligibleForSearch = true
            activity.isEligibleForPrediction = true
            
            let attributes = CSSearchableItemAttributeSet(contentType: UTType.item)
            attributes.contentDescription = "Generate a QR Code"
            activity.contentAttributeSet = attributes
            #endif
            
            activity.isEligibleForHandoff = true
            activity.title = "\(generatorType.name) Generator"
            activity.userInfo = ["genId": generatorType.id]
            activity.becomeCurrent()
        }
        #if os(iOS)
        .onChange(of: qrCode.imgData, perform: {data in
            externalDisplayContent.codeImage = data
            externalDisplayContent.backgroundColor = qrCode.backgroundColor
        })
        #endif
    }
}

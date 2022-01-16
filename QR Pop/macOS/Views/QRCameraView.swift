//
//  QRCameraView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 1/16/22.
//

import SwiftUI
import AVFoundation
import EFQRCode

struct QRCameraView: View {
    @StateObject var qrCode = QRCode()
    
    //Unique variables for link
    @State private var scanContent: String = ""
    @State private var hasScanned: Bool = false
    @State private var showHelp: Bool = false
    @State private var noCodeFound: Bool = false
    @State private var showScannedData: Bool = false
    
    func handleScan(result: String?) {
        withAnimation() {
            hasScanned = true
        }
        if (result != nil) {
            qrCode.setContent(string: result!)
        } else {
            print("Scanning failed!")
        }
    }
    
    var body: some View {
        ScrollView {
            HStack {
                Spacer()
                VStack {
                    if hasScanned {
                    QRImage()
                        .environmentObject(qrCode)
                        .padding()
                    
                    HStack {
                        Spacer()
                        Button(
                        action: {
                            withAnimation() {
                                hasScanned = false
                            }
                            scanContent = ""
                            qrCode.reset()
                        }) {
                            Label("Scan Another Code", systemImage: "camera")
                        }.buttonStyle(.bordered)
                        Spacer()
                    }
                        
                    QRCodeDesigner()
                        .environmentObject(qrCode)
                        .padding(.horizontal)
                        .frame(maxWidth: 450)
                    } else {
                        CodeScannerControllerRepresentable(completionHandler: self.handleScan)
                            .frame(minWidth: 300, maxWidth: 500, minHeight: 300, maxHeight: 400)
                            .aspectRatio(4/3, contentMode: .fit)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(Color.primary, lineWidth: 2)
                            )
                            .padding(20)
                            .transition(.scale)
                        
                        Text("Scan a QR Code to Duplicate It")
                            .font(.headline)
                        Button(
                        action: {
                            let panel = NSOpenPanel()
                            panel.canChooseDirectories = false
                            panel.canChooseFiles = true
                            panel.allowsMultipleSelection = false
                            panel.title = "Pick an Image to Scan"
                            panel.allowedContentTypes = [UTType.png, UTType.jpeg]
                            if panel.runModal() == .OK {
                                let image = NSImage(byReferencing: panel.url!)
                                let result = EFQRCode.recognize(image.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
                                if (!result.isEmpty) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        qrCode.setContent(string: result.first!)
                                        withAnimation() {
                                            hasScanned = true
                                        }
                                    }
                                } else {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        noCodeFound = true
                                    }
                                }
                            }
                        }) {
                            Label("Duplicate Code from Image", systemImage: "photo.on.rectangle.angled")
                        }.buttonStyle(.bordered)
                        .padding()
                    }
                }
                Spacer()
            }
        }.navigationTitle("Duplicate")
        .alert(isPresented: $noCodeFound, content: {
            Alert(title: Text("No Code Found in Image"))
        })
        .sheet(isPresented: $showHelp, content: {
            ScannerHelpModal(isPresented: $showHelp)
        })
        .sheet(isPresented: $showScannedData) {
            ModalNavbar(navigationTitle: "Scan Result", showModal: $showScannedData) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Encoded Data")
                                .font(.largeTitle)
                                .bold()
                            Spacer()
                        }
                        Text(verbatim: "\(qrCode.getContent())")
                    }.padding()
                }
            }
        }
        .toolbar(content: {
            HStack{
                Button(
                action: {
                    showHelp.toggle()
                }) {
                    Label("Help", systemImage: "questionmark.circle")
                }
                if hasScanned {
                    Button(
                    action: {
                        showScannedData.toggle()
                    }) {
                        Label("Show Scanned Data", systemImage: "rectangle.and.text.magnifyingglass")
                    }
                    ShareButton(shareContent: [qrCode.imgData.image], buttonTitle: "Share")
                }
            }
        })
    }
}

private struct ScannerHelpModal: View {
    @Binding var isPresented: Bool
    var body: some View {
        ModalNavbar(navigationTitle: "Duplicate Help", showModal: $isPresented) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Using Duplicate")
                            .font(.largeTitle)
                            .bold()
                    Group {
                        Text("How does it work?")
                            .font(.headline)
                        Text("QR Pop allows you to recreate a QR code by scanning it. It'll take all of the data inside of that QR code, and place it into a new one! This is a super convenient way to duplicate codes that you didn't save.")
                        Text("Why does QR Pop's code look different from the one I scanned?")
                            .font(.headline)
                        Text("There are a lot of factors that can influence how a QR code looks besides just the information stored within it. While the two codes may not be identical in appearance, they both do the same thing when scanned.")
                        Text("I can't scan my code!")
                            .font(.headline)
                        Text("Make sure the QR code you want to duplicate isn't damaged in any way. Can you scan it with the regular camera app? If the code can't be scanned, it can't be duplicated.")
                    }
                }.padding()
            }
        }
    }
}

struct QRCameraView_Previews: PreviewProvider {
    static var previews: some View {
        QRLinkView()
    }
}

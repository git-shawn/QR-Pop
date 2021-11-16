//
//  CodeScannerView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 11/15/21.
//

import SwiftUI
import CoreLocation
import Contacts
import UniformTypeIdentifiers

struct CodeReaderView: View {
    var body: some View {
        TabView {
            CodeImportView()
                .tabItem({
                    Text("Import")
                })
            CodeScannerView()
                .tabItem({
                    Text("Camera")
                })
        }.padding()
        .navigationTitle("QR Code Reader")
    }
}

// - MARK: File picker based QR code scanner and functions.

struct CodeImportView: View {
    @State private var dropping: Bool = false
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 10) {
                Image(systemName: "cursorarrow.rays")
                    .font(.system(size: 64))
                    .foregroundColor(.secondary)
                Button(action: {
                    presentFilePicker()
                }) {
                    Text("Import an Image")
                }.background(.regularMaterial)
            }.onDrop(of: [UTType.fileURL], isTargeted: $dropping, perform: {info in
                guard let item = info.first else { return false }
                if item.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                    item.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil, completionHandler: { data, error in
                        if let data = data as? Data {
                            let url = URL(dataRepresentation: data, relativeTo: nil)
                            if (["png", "jpg", "jpeg"]).contains(url?.pathExtension) {
                                print("\(url!.absoluteString)")
                            }
                        }
                    })
                } else {
                    return false
                }
                return true
            })
                .frame(width: 400, height: 300)
                .background(.ultraThickMaterial)
                .scaleEffect(dropping ? 1.1 : 1)
                .animation(.spring(), value: dropping)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
            Text("Drag an image to scan it")
                .font(.headline)
            Spacer()
        }.padding()
    }
    
    private func presentFilePicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.canDownloadUbiquitousContents = true
        panel.title = "Select an Image"
        panel.allowedContentTypes = [UTType.image]
        panel.message = "Select an image that contains a QR code to scan."
        
        let response = panel.runModal()
        if response == NSApplication.ModalResponse.OK {
            print(panel.url?.absoluteString)
        }
    }
}

// - MARK: Camera-based QR code scanner and functions

struct CodeScannerView: View {
    @State private var scanComplete: Bool = false
    @State private var payload: String = ""
    @State private var type: QRVisionActor.QRCodeDataType = .unknown
    @State private var buttonText: String = "Act"
    @State private var messageContent: String = ""
    
    @AppStorage("openShortcutsAuto") var openShortcutsAuto: Bool = false
    let visionActor = QRVisionActor()
    
    var body: some View {
        VStack {
            if (scanComplete) {
                ScrollView {
                    VStack {
                        ZStack(alignment: .bottomTrailing) {
                            QRImage(qrCode: Binding.constant(QRCode().generate(content: payload, fg: .primary, bg: Color("SystemBkg"))), bg: Binding.constant(Color("SystemBkg")), fg: Binding.constant(.primary))
                                .padding()
                                .frame(width: 400, height: 300)
                                .background(Color("SystemBkg"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .zIndex(1)
                            Button(action: {
                                scanComplete = false
                            }) {
                               Label("Scan Another Code", systemImage: "arrow.clockwise.circle.fill")
                                    .labelStyle(IconOnlyLabelStyle())
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(Color("secondaryLabel"), Color("SystemFill"))
                                    .font(.system(size: 32))
                            }.buttonStyle(.plain)
                            .padding(10)
                            .zIndex(2)
                        }.padding()
                        VStack(alignment: .center, spacing: 10) {
                            Text("Results:")
                                .font(.headline)
                                .padding(.top)
                            if (payload.contains("shortcuts:")) {
                                Toggle("Open Shortcuts Automatically?", isOn: $openShortcutsAuto)
                                    .toggleStyle(.switch)
                                    .tint(.accentColor)
                            } else {
                            Text("\(messageContent)")
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            }
                            if type != .unknown {
                                Button(action: {
                                    visionActor.handle(payload: payload, type: type)
                                }) {
                                    Text("\(buttonText)")
                                }.padding()
                            } else {
                                Spacer().frame(height: 20)
                            }
                        }.frame(width: 400)
                        .background(.ultraThickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding()
                    }.padding()
                    HStack {
                        Spacer()
                    }
                }
            } else {
                VStack {
                    QRVisionViewControllerRepresentable(completionHandler: {payload in scanDidComplete(payload: payload)})
                        .frame(width: 400, height: 300)
                        .background(.ultraThickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding()
                    Text("Scan a QR code")
                        .font(.headline)
                    Spacer()
                }.padding()
            }
        }
    }
    
    private func scanDidComplete(payload: String?) {
        if payload != nil {
            type = visionActor.interpret(payload: payload)
            self.payload = payload!
            withAnimation(.spring()) {
                scanComplete = true
                labelResults()
            }
        }
    }
    
    private func labelResults() {
        switch type {
        case .url:
            if payload.contains("sms:") {
                messageContent = "Send a message to \(String(payload[(payload.index(payload.startIndex, offsetBy: 4))...]))"
                buttonText = "Send Message"
            } else if payload.contains("facetime:") {
                messageContent = "Start a facetime video call with \(String(payload[(payload.index(payload.startIndex, offsetBy: 9))...]))"
                buttonText = "Start Facetime"
            } else if payload.contains("tel:") {
                messageContent = "Call \(String(payload[(payload.index(payload.startIndex, offsetBy: 4))...]))"
                buttonText = "Place Call"
            } else if payload.contains("mailto:") {
                messageContent = "Send an email to \(String(payload[(payload.index(payload.startIndex, offsetBy: 7))...]))"
                buttonText = "Open Mail"
            } else if payload.contains("facetime-audio:") {
                messageContent = "Start a facetime audio call with \(String(payload[(payload.index(payload.startIndex, offsetBy: 15))...]))"
                buttonText = "Start Facetime"
            } else if payload.contains("shortcuts:") {
                if openShortcutsAuto {
                    visionActor.handle(payload: payload, type: type)
                    buttonText = "Run Shortcut Again"
                } else {
                    buttonText = "Run Shortcut"
                }
            } else {
                messageContent = "Visit \(payload)"
                buttonText = "Open Link"
            }
        case .contact:
            messageContent = "Contact Information Found"
            buttonText = "View Contact"
        case .event:
            messageContent = "Event Found"
            buttonText = "View Event"
        case .location:
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString((String(payload[(payload.index(payload.startIndex, offsetBy: 4))...]))) { (placemarks, error) in
                guard
                    let placemarks = placemarks
                else {
                    messageContent = "A location was found at the coordinates \(String(payload[(payload.index(payload.startIndex, offsetBy: 4))...]))"
                    return
                }
                messageContent = "\(CNPostalAddressFormatter().string(from: (placemarks.first?.postalAddress)!))"
            }
            buttonText = "Open in Maps"
        case .network:
            buttonText = "Connect to Network"
        case .plaintext:
            messageContent = payload
            buttonText = "Copy Text"
        case .unknown:
            messageContent = "No Usable Data Found"
        }
    }
}

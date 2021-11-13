//
//  QRContactView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI
import Contacts

struct QRContactView: View {
    @State private var qrData: Data
    @State private var bgColor: Color = .white
    @State private var fgColor: Color = .black
    private let qrCode = QRCode()
    #if os(macOS)
    @State private var showDesignPopover: Bool = false
    #endif
    
    //Unique variables for contacts
    @State private var showPicker = false
    @State private var canGenerateCode = false
    @State private var contact: CNContact = CNContact()
    
    init() {
        qrData = qrCode.generate(content: "", fg: .black, bg: .white)
    }
    
    private func generateCode() {
        if canGenerateCode {
            qrData = qrCode.generateContact(contact: contact, bg: bgColor, fg: fgColor)
        } else {
            qrData = qrCode.generate(content: "", fg: fgColor, bg: bgColor)
        }
    }
    
    var body: some View {
        ScrollView {
            if (CNContactStore.authorizationStatus(for: .contacts) != .denied) {
                QRImage(qrCode: $qrData, bg: $bgColor, fg: $fgColor)
                    .padding()
                
                Button(action: {
                    showPicker = true
                }) {
                    Label("Chose a Contact", systemImage: "person.crop.circle")
                        .padding(10)
                    #if os(iOS)
                        .frame(maxWidth: 350)
                    #endif
                }
                .padding()
                #if os(iOS)
                .buttonStyle(.bordered)
                #else
                .overlay(ContactPicker(contact: $contact, isPresented: $showPicker))
                .onChange(of: contact) { value in
                    canGenerateCode = true
                    generateCode()
                }
                #endif
                
                // This is a dummy view and won't appeaar in the UI.
                #if os(iOS)
                ContactPicker(
                    showPicker: $showPicker,
                    onSelectContact: {c in
                        self.contact = c
                    }
                ).onChange(of: contact) { value in
                    canGenerateCode = true
                    generateCode()
                }
                #endif
                
                #if os(iOS)
                Divider()
                    .padding(.leading)
                    .padding(.bottom)
                
                QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
                .onChange(of: [bgColor, fgColor]) {_ in
                    generateCode()
                }
                #endif
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Spacer()
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .font(.system(size: 64))
                            .padding()
                        Spacer()
                    }
                    Text("QR Pop Needs Permission for This")
                        .font(.largeTitle)
                        .bold()
                    Text("QR Pop needs permission to access your Address Book to generate codes from your contacts. You can enable this in the Settings app using the button below.\n\nRest assured, your contact information will never leave your device. QR Pop works entirely offline and contains no trackers what-so-ever.\n\nAlternatively, you can use some of QR Pop's other generators (like email, phone number, etc.) if you don't want to share an entire contact.")
                    Spacer()
                    #if os(iOS)
                    Button(action: {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else {
                           return
                        }
                        if UIApplication.shared.canOpenURL(url) {
                           UIApplication.shared.open(url, options: [:])
                        }
                    }) {
                        Text("Open App Settings")
                        .padding(10)
                        .frame(maxWidth: .infinity)
                    }.buttonStyle(.borderedProminent)
                    .padding()
                    #else
                    HStack {
                        Spacer()
                        Button(action: {
                            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Contacts")!)
                        }) {
                            Text("Open Privacy Settings")
                        }.buttonStyle(.borderedProminent)
                        .padding()
                        Spacer()
                    }
                    #endif
                }.padding()
            }
        }.navigationTitle("Contact Generator")
        .toolbar(content: {
            HStack{
                #if os(macOS)
                Button(
                action: {
                    showDesignPopover.toggle()
                }){
                    Image(systemName: "paintpalette")
                }
                .popover(isPresented: $showDesignPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                    QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
                    .onChange(of: [bgColor, fgColor]) {_ in
                        generateCode()
                    }.frame(minWidth: 300)
                }
                #endif
                Button(
                action: {
                    DispatchQueue.main.async {
                        fgColor = .black
                        bgColor = .white
                        canGenerateCode = false
                        qrData = qrCode.generate(content: "", fg: .black, bg: .white)
                    }
                }){
                    Image(systemName: "trash")
                }
                #if os(macOS)
                SaveButton(qrCode: qrData)
                #endif
                ShareButton(shareContent: [qrData.image], buttonTitle: "Share")
            }
        })
    }
}

struct QRContactView_Previews: PreviewProvider {
    static var previews: some View {
        QRContactView()
    }
}

//
//  ContactQRView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/23/21.
//

import SwiftUI
import Contacts

struct ContactQRView: View {
    
    // Standard QR Screen states
    @State private var image: NSImage
    @State private var bgColor: Color = Color.white
    @State private var fgColor: Color = Color.black
    @State private var isSharing: Bool = false
    let qrCode = QRCode()
    
    init() {
        self.image = QRCode().generate(content: "", fg: .black, bg: .white)
    }
    
    // Contact states
    @State private var contact: CNContact = CNContact()
    @State private var shouldLoadContact: Bool = false
    @State private var showPicker: Bool = false
    
    var body: some View {
        ScrollView {
            HStack(alignment: .center, spacing: 20) {
                QRImage(qrCode: $image, bg: $bgColor)
                
                QRDesignPanel(bg: $bgColor, fg: $fgColor)
                .onChange(of: [bgColor, fgColor]) {_ in
                    if (shouldLoadContact) {
                        image = qrCode.generateContact(contact: contact, bg: bgColor, fg: fgColor)
                    } else {
                        image = qrCode.generate(content: "", fg: fgColor, bg: bgColor)
                    }
                }
            }.padding()
            
            Button(action: {
                showPicker = true
            }) {
                Label("Chose a Contact", systemImage: "person.crop.circle")
                    .foregroundColor(Color(NSColor.controlTextColor))
                    .padding()
                    .background(
                        Capsule()
                            .foregroundColor(Color(NSColor.controlColor))
                    )
            }.padding(.vertical)
            .buttonStyle(PlainButtonStyle())
            .background(ContactPicker(contact: $contact, isPresented: $showPicker))
            .onChange(of: contact, perform: {_ in
                shouldLoadContact = true
                image = qrCode.generateContact(contact: contact, bg: bgColor, fg: fgColor)
            })
        }.navigationTitle("Contact QR Generator")
        .toolbar {
            HStack {
                Button(action: {
                    bgColor = .white
                    fgColor = .black
                    shouldLoadContact = false
                    image = qrCode.generateContact(contact: contact, bg: bgColor, fg: fgColor)
                }) {
                    Image(systemName: "trash")
                }.accessibilityHint("Erase QR Code")
                .help("Erase QR Code")
                Divider()
                Button(action: {
                    ImageSaver().save(image: image)
                }) {
                    Image(systemName: "square.and.arrow.down")
                }.accessibilityLabel("Save")
                .accessibilityHint("Save QR Code")
                .help("Save QR Code")
                Button(action: {
                    isSharing = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                    .accessibilityHint("Share QR Code")
                    .help("Share QR Code")
                    .background(SharePicker(isPresented: $isSharing, sharingItems: [image]))
                }
            }
        }
    }
}

struct ContactQRView_Previews: PreviewProvider {
    static var previews: some View {
        ContactQRView()
    }
}

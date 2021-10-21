//
//  ContactQRView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/17/21.
//

import SwiftUI
import UniformTypeIdentifiers
import Contacts

struct ContactQRView: View {
    let qrCode = QRCode()
    let imageSaver = ImageSaver()
    
    //QR View standard variables
    @State private var bgColor = Color.white
    @State private var fgColor = Color.black
    @State private var showShare = false
    @State private var content: Data?

    //Unique variables for contact
    @State private var showPicker = false
    @State private var showMaker = false
    @State private var contact: CNContact?
    @State private var newContact = CNContact()
    
    init() {
        _content = State(initialValue: QRCode().generate(content: "", bg: .white, fg: .black))
    }
    
    /// Generate a QR code from a URL
    var body: some View {
        ScrollView {
            VStack() {
                
                QRImageView(content: $content, share: $showShare, bg: $bgColor)
                
                Button(action: {
                    showPicker = true
                }) {
                    Label("Chose a Contact", systemImage: "person.crop.circle")
                        .font(.headline)
                        .frame(width: 300, height: 40)
                }.buttonStyle(.bordered)
                .padding(.vertical)
                
                // This is a dummy view and won't appeaar in the UI.
                ContactPicker(
                    showPicker: $showPicker,
                    onSelectContact: {c in
                        self.contact = c
                    }
                ).onChange(of: contact) { value in
                    content = qrCode.generateContact(contact: contact!, bg: bgColor, fg: fgColor)
                }
                
                QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
                    .onChange(of: [bgColor, fgColor]) { value in
                        if (contact == nil) {
                            content = qrCode.generate(content: "", bg: bgColor, fg: fgColor)
                        } else {
                            content = qrCode.generateContact(contact: contact!, bg: bgColor, fg: fgColor)
                        }
                    }
                
            }.padding(.top)
        }.navigationBarTitle(Text("Contact QR Code"), displayMode: .large)
        .toolbar(content: {
            HStack{
                Button(
                action: {
                    showShareSheet(with: [UIImage(data: content!)!])
                }){
                    Image(systemName: "square.and.arrow.up")
                }
            }
        })
    }
}

struct ContactQRView_Previews: PreviewProvider {
    static var previews: some View {
        ContactQRView()
    }
}

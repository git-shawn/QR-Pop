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
                
                HStack {
                    Spacer()
                    Button(action: {
                        showPicker = true
                    }) {
                        Label("Chose", systemImage: "person.crop.circle")
                            .font(.headline)
                            .frame(width: 130, height: 30)
                    }.buttonStyle(.bordered)
                    Spacer()
                    Button(action: {
                        showMaker = true
                    }) {
                        Label("Create", systemImage: "person.crop.circle.badge.plus")
                            .font(.headline)
                            .frame(width: 130, height: 30)
                    }.buttonStyle(.bordered)
                    Spacer()
                }.padding(.vertical)
                .sheet(isPresented: $showMaker) {
                    NavigationView {
                        //MARK: - This is whack. Should fix.
                        ContactMaker(contact: $contact, presentingEditContact: $showMaker)
                            .background(Color(UIColor.secondarySystemBackground))
                    }.onChange(of: contact) { value in
                        content = qrCode.generateContact(contact: contact!, bg: bgColor, fg: fgColor)
                    }
                }
                
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
                    showShare = true
                }){
                    Image(systemName: "square.and.arrow.up")
                }.sheet(isPresented: $showShare, content: {
                    ZStack {
                    ActivityViewController(activityItems: [UIImage(data: content!)!])
                    }.background(.ultraThickMaterial)
                })
            }
        })
    }
}

struct ContactQRView_Previews: PreviewProvider {
    static var previews: some View {
        ContactQRView()
    }
}

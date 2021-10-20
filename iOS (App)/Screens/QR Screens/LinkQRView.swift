//
//  LinkQRView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/17/21.
//

import SwiftUI
import UniformTypeIdentifiers

struct LinkQRView: View {
    let qrCode = QRCode()
    let imageSaver = ImageSaver()
    
    //QR View standard variables
    @State private var bgColor = Color.white
    @State private var fgColor = Color.black
    @State private var showShare = false
    @State private var content: Data?
    
    //Unique variables for link
    @State private var text: String = ""
    
    init() {
        _content = State(initialValue: QRCode().generate(content: "", bg: .white, fg: .black))
    }
    
    /// Generate a QR code from a URL
    var body: some View {
        ScrollView {
            VStack() {
                
                QRImageView(content: $content, share: $showShare, bg: $bgColor)
                
                //Accept inputs to generate QR code
                TextField("Enter URL", text: $text)
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                    .padding(.top, 10)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .submitLabel(.done)
                    .disableAutocorrection(true)
                    .onChange(of: text) { value in
                        content = QRCode().generate(content: text, bg: bgColor, fg: fgColor)
                    }
                Divider()
                    .padding(.leading)
                    .padding(.bottom)
                
                QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
                .onChange(of: [bgColor, fgColor]) { value in
                    content = qrCode.generate(content: text, bg: bgColor, fg: fgColor)
                }
                
            }.padding(.top)
        }.navigationBarTitle(Text("URL QR Code"), displayMode: .large)
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

struct LinkQRView_Previews: PreviewProvider {
    static var previews: some View {
        LinkQRView()
    }
}

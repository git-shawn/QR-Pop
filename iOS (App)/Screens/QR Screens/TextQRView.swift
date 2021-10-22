//
//  TextQRView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/21/21.
//

import SwiftUI

import SwiftUI
import UniformTypeIdentifiers

/// A QR code builder view to make codes for plaintext
struct TextQRView: View {
    let qrCode = QRCode()
    let imageSaver = ImageSaver()
    
    //QR View standard variables
    @State private var bgColor = Color.white
    @State private var fgColor = Color.black
    @State private var content: Data?
    
    //Unique variables for text
    @State private var text: String = ""
    @State private var showNotice: Bool = false
    
    init() {
        _content = State(initialValue: QRCode().generate(content: "", bg: .white, fg: .black))
    }
    
    /// Generate a QR code from a String
    var body: some View {
        ScrollView {
            VStack() {
                
                QRImageView(content: $content, bg: $bgColor)
                
                //Accept inputs to generate QR code
                TextEditorModal(text: $text)
                    .onChange(of: text) { value in
                        content = QRCode().generate(content: text, bg: bgColor, fg: fgColor, dataEncode: .utf8)
                    }
                
                QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
                .onChange(of: [bgColor, fgColor]) { value in
                    content = qrCode.generate(content: text, bg: bgColor, fg: fgColor, dataEncode: .utf8)
                }
                
            }.padding(.top)
        }.navigationBarTitle(Text("Text QR Code"), displayMode: .large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(
                    action: {
                        showShareSheet(with: [UIImage(data: content!)!])
                    }){
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

struct TextQRView_Previews: PreviewProvider {
    static var previews: some View {
        TextQRView()
    }
}

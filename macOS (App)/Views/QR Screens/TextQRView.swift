//
//  TextQRView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/23/21.
//

import SwiftUI

struct TextQRView: View {
    
    // Standard QR Screen states
    @State private var image: NSImage
    @State private var bgColor: Color = Color.white
    @State private var fgColor: Color = Color.black
    @State private var isSharing: Bool = false
    let qrCode = QRCode()
    
    init() {
        self.image = QRCode().generate(content: "", fg: .black, bg: .white)
    }
    
    // Text states
    @State private var text: String = ""
    
    var body: some View {
        ScrollView {
            HStack(alignment: .center, spacing: 20) {
                QRImage(qrCode: $image, bg: $bgColor)
                
                QRDesignPanel(bg: $bgColor, fg: $fgColor)
                .onChange(of: [bgColor, fgColor], perform: {_ in
                    image = qrCode.generate(content: text, fg: fgColor, bg: bgColor, encoding: .utf8)
                })
            }.padding()
            TextEditor(text: $text)
                .frame(width: 490, height: 80)
                .padding(.horizontal, 10)
                .padding(.top, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 510, height: 100)
                        .foregroundColor(Color(NSColor.textBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke()
                                .foregroundColor(Color(NSColor.underPageBackgroundColor))
                        )
                )
                .padding(.bottom)
                .onChange(of: text, perform: {_ in
                    if text.count < 2000 {
                        image = qrCode.generate(content: text, fg: fgColor, bg: bgColor, encoding: .utf8)
                    } else {
                        text = String(text.prefix(2000))
                    }
                })
            HStack {
                Spacer()
                Text("\(text.count)/2000")
                    .padding(.trailing)
                    .foregroundColor((text.count < 2000) ? .secondary : .red)
            }.frame(maxWidth: 500)
            .padding(.bottom)
        }.navigationTitle("Text QR Generator")
        .toolbar {
            HStack {
                Button(action: {
                    text = ""
                    bgColor = .white
                    fgColor = .black
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

struct TextQRView_Previews: PreviewProvider {
    static var previews: some View {
        TextQRView()
    }
}

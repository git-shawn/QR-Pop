//
//  QRTextView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRTextView: View {
    @State private var qrData: Data
    @State private var bgColor: Color = .white
    @State private var fgColor: Color = .black
    private let qrCode = QRCode()
    #if os(macOS)
    @State private var showDesignPopover: Bool = false
    #endif
    
    //Unique variables for text
    @State private var text: String = ""
    @State private var showTextModal: Bool = false
    
    init() {
        qrData = qrCode.generate(content: "", fg: .black, bg: .white)
    }
    
    var body: some View {
        ScrollView {
            QRImage(qrCode: $qrData, bg: $bgColor, fg: $fgColor)
                .padding()
            
            TextEditorModal(showTextEditor: $showTextModal, text: $text)
                .onChange(of: showTextModal) {_ in
                    qrData = qrCode.generate(content: text, fg: fgColor, bg: bgColor, encoding: .utf8)
                }
            
            #if os(iOS)
            QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
            .onChange(of: [bgColor, fgColor]) { value in
                qrData = qrCode.generate(content: text, fg: fgColor, bg: bgColor, encoding: .utf8)
            }
            #endif
        }.navigationTitle("Text Generator")
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
                    .onChange(of: [bgColor, fgColor]) { value in
                        qrData = qrCode.generate(content: text, fg: fgColor, bg: bgColor, encoding: .utf8)
                    }.frame(minWidth: 300)
                }
                #endif
                Button(
                action: {
                    text = ""
                    fgColor = .black
                    bgColor = .white
                    qrData = QRCode().generate(content: "", fg: .black, bg: .white)
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

struct QRTextView_Previews: PreviewProvider {
    static var previews: some View {
        QRTextView()
    }
}

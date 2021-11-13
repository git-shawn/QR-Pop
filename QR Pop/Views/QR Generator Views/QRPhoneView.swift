//
//  QRPhoneView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRPhoneView: View {
    @State private var qrData: Data
    @State private var bgColor: Color = .white
    @State private var fgColor: Color = .black
    private let qrCode = QRCode()
    #if os(macOS)
    @State private var showDesignPopover: Bool = false
    #endif
    
    //Unique variables for phone numbers
    @State private var text: String = ""
    
    init() {
        qrData = qrCode.generate(content: "", fg: .black, bg: .white)
    }
    
    var body: some View {
        ScrollView {
            QRImage(qrCode: $qrData, bg: $bgColor, fg: $fgColor)
                .padding()
            
            TextField("Enter Phone Number", text: $text)
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.phonePad)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onChange(of: text) { value in
                    qrData = QRCode().generate(content: ("tel:"+text), fg: fgColor, bg: bgColor)
                }
            
            #if os(iOS)
            QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
            .onChange(of: [bgColor, fgColor]) { value in
                qrData = qrCode.generate(content: ("tel:"+text), fg: fgColor, bg: bgColor)
            }
            #endif
        }.navigationTitle("Phone Generator")
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
                        qrData = qrCode.generate(content: ("tel:"+text), fg: fgColor, bg: bgColor)
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

struct QRPhoneView_Previews: PreviewProvider {
    static var previews: some View {
        QRPhoneView()
    }
}

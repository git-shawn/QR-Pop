//
//  QRFacetimeView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRFacetimeView: View {
    @State private var qrData: Data
    @State private var bgColor: Color = .white
    @State private var fgColor: Color = .black
    private let qrCode = QRCode()
    #if os(macOS)
    @State private var showDesignPopover: Bool = false
    #endif
    
    //Unique variables for facetime
    @State private var text: String = ""
    @State private var isFacetimeAudio: Bool = false
    
    init() {
        qrData = qrCode.generate(content: "", fg: .black, bg: .white)
    }
    
    var body: some View {
        ScrollView {
            QRImage(qrCode: $qrData, bg: $bgColor, fg: $fgColor)
                .padding()
            
            Picker("FaceTime Video or Audio", selection: $isFacetimeAudio) {
                Text("Video").tag(false)
                Text("Audio").tag(true)
            }
                .padding()
                .pickerStyle(.segmented)
                .onChange(of: isFacetimeAudio) { value in
                    if (value) {
                        qrData = QRCode().generate(content: ("facetime-audio:"+text), fg: fgColor, bg: bgColor)
                    } else {
                        qrData = QRCode().generate(content: ("facetime:"+text), fg: fgColor, bg: bgColor)
                    }
                }
            
            TextField("Enter Phone Number or Email", text: $text)
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.namePhonePad)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onChange(of: text) { value in
                    if (isFacetimeAudio) {
                        qrData = QRCode().generate(content: ("facetime-audio:"+value), fg: fgColor, bg: bgColor)
                    } else {
                        qrData = QRCode().generate(content: ("facetime:"+value), fg: fgColor, bg: bgColor)
                    }
                }
            
            #if os(iOS)
            QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
            .onChange(of: [bgColor, fgColor]) {_ in
                if (isFacetimeAudio) {
                    qrData = QRCode().generate(content: ("facetime-audio:"+text), fg: fgColor, bg: bgColor)
                } else {
                    qrData = QRCode().generate(content: ("facetime:"+text), fg: fgColor, bg: bgColor)
                }
            }
            #endif
        }.navigationTitle("FaceTime Generator")
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
                        if (isFacetimeAudio) {
                            qrData = QRCode().generate(content: ("facetime-audio:"+text), fg: fgColor, bg: bgColor)
                        } else {
                            qrData = QRCode().generate(content: ("facetime:"+text), fg: fgColor, bg: bgColor)
                        }
                    }.frame(minWidth: 300)
                }
                #endif
                Button(
                action: {
                    text = ""
                    isFacetimeAudio = false
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

struct QRFacetimeView_Previews: PreviewProvider {
    static var previews: some View {
        QRFacetimeView()
    }
}

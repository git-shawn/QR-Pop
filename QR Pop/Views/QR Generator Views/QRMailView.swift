//
//  QRMailView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRMailView: View {
    @State private var qrData: Data
    @State private var bgColor: Color = .white
    @State private var fgColor: Color = .black
    private let qrCode = QRCode()
    #if os(macOS)
    @State private var showDesignPopover: Bool = false
    #endif
    
    //Unique variables for emails
    @State private var email: String = ""
    @State private var subject: String = ""
    @State private var emailBody: String = ""
    @State private var wholeMessage: String = ""
    @State private var showTextModal: Bool = false
    
    init() {
        qrData = qrCode.generate(content: "", fg: .black, bg: .white, encoding: .utf8)
    }
    
    var body: some View {
        ScrollView {
            QRImage(qrCode: $qrData, bg: $bgColor, fg: $fgColor)
                .padding()
            
            TextField("Enter Email Address", text: $email)
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onChange(of: email) { value in
                    constructWholeMessage()
                    qrData = QRCode().generate(content: (wholeMessage), fg: fgColor, bg: bgColor, encoding: .utf8)
                }
            
            TextField("Enter Email Subject", text: $email)
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.default)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onChange(of: email) { value in
                    constructWholeMessage()
                    qrData = QRCode().generate(content: (wholeMessage), fg: fgColor, bg: bgColor, encoding: .utf8)
                }
            
            TextEditorModal(showTextEditor: $showTextModal, text: $emailBody)
                .onChange(of: showTextModal) {_ in
                    constructWholeMessage()
                    qrData = QRCode().generate(content: (wholeMessage), fg: fgColor, bg: bgColor, encoding: .utf8)
                }
            
            #if os(iOS)
            QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
            .onChange(of: [bgColor, fgColor]) { value in
                constructWholeMessage()
                qrData = QRCode().generate(content: (wholeMessage), fg: fgColor, bg: bgColor, encoding: .utf8)
            }
            #endif
        }.navigationTitle("Email Generator")
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
                        constructWholeMessage()
                        qrData = QRCode().generate(content: (wholeMessage), fg: fgColor, bg: bgColor, encoding: .utf8)
                    }.frame(minWidth: 300)
                }
                #endif
                Button(
                action: {
                    email = ""
                    subject = ""
                    emailBody = ""
                    fgColor = .black
                    bgColor = .white
                    qrData = QRCode().generate(content: "", fg: .black, bg: .white, encoding: .utf8)
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
    
    private func constructWholeMessage() {
        if !emailBody.isEmpty && !subject.isEmpty {
            wholeMessage = "mailto:\(email)?subject=\(subject)&body=\(emailBody)"
        } else if emailBody.isEmpty && !subject.isEmpty {
            wholeMessage = "mailto:\(email)?subject=\(subject)"
        } else if !emailBody.isEmpty && subject.isEmpty {
            wholeMessage = "mailto:\(email)?body=\(emailBody)"
        } else {
            wholeMessage = "mailto:\(email)"
        }
    }
}

struct QRMailView_Previews: PreviewProvider {
    static var previews: some View {
        QRMailView()
    }
}

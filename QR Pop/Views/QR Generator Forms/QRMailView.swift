//
//  QRMailView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRMailView: View {
    @EnvironmentObject var qrCode: QRCode

    @State private var email: String = ""
    @State private var subject: String = ""
    @State private var emailBody: String = ""
    @State private var wholeMessage: String = ""
    @State private var showTextModal: Bool = false
    
    private func setCodeContent() {
        if !emailBody.isEmpty && !subject.isEmpty {
            wholeMessage = "mailto:\(email)?subject=\(subject)&body=\(emailBody)"
        } else if emailBody.isEmpty && !subject.isEmpty {
            wholeMessage = "mailto:\(email)?subject=\(subject)"
        } else if !emailBody.isEmpty && subject.isEmpty {
            wholeMessage = "mailto:\(email)?body=\(emailBody)"
        } else {
            wholeMessage = "mailto:\(email)"
        }
        qrCode.setContent(string: wholeMessage)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            TextField("Enter Email Address", text: $email)
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onChange(of: email) { value in
                    setCodeContent()
                }
            
            TextField("Enter Email Subject", text: $subject)
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.default)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onChange(of: subject) { value in
                    setCodeContent()
                }
            
            TextEditorModal(showTextEditor: $showTextModal, text: $emailBody)
                .onChange(of: showTextModal) {_ in
                    setCodeContent()
                }
        }.onChange(of: qrCode.codeContent, perform: {value in
            if (value.isEmpty) {
                email = ""
                subject = ""
                emailBody = ""
                wholeMessage = ""
            }
        })
    }
}

struct QRMailView_Previews: PreviewProvider {
    static var previews: some View {
        QRMailView()
    }
}

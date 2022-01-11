//
//  QRMailView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRMailView: View {
    @EnvironmentObject var qrCode: QRCode
    
    @State private var showTextModal: Bool = false
    
    private func setCodeContent() {
        let wholeMessage = "mailto:\(qrCode.formStates[0])?subject=\(qrCode.formStates[1])&body=\(qrCode.formStates[2])"
        qrCode.setContent(string: wholeMessage)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            TextField("Enter Email Address", text: $qrCode.formStates[0])
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onChange(of: qrCode.formStates[0]) {value in
                    setCodeContent()
                }
            
            TextField("Enter Email Subject", text: $qrCode.formStates[1])
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.default)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onChange(of: qrCode.formStates[1]) {value in
                    setCodeContent()
                }
            
            TextEditorModal(showTextEditor: $showTextModal, text: $qrCode.formStates[2])
                .onChange(of: showTextModal) {_ in
                    setCodeContent()
                }
        }
    }
}

struct QRMailView_Previews: PreviewProvider {
    static var previews: some View {
        QRMailView()
    }
}

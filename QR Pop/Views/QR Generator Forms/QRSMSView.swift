//
//  QRSMSView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRSMSView: View {
    @EnvironmentObject var qrCode: QRCode

    @State private var showTextModal: Bool = false
    @State private var number: String = ""
    @State private var text: String = ""
    
    private func setCodeContent() {
        let content = "smsto:\(number):\(text)"
        qrCode.setContent(string: content)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            TextField("Enter Phone Number", text: $number)
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.phonePad)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onChange(of: text) { value in
                    setCodeContent()
                }
            TextEditorModal(showTextEditor: $showTextModal, text: $text)
                .onChange(of: showTextModal) {_ in
                    setCodeContent()
                }
        }.onChange(of: qrCode.codeContent, perform: {value in
            if (value.isEmpty) {
                number = ""
                text = ""
            }
        })
    }
}

struct QRSMSView_Previews: PreviewProvider {
    static var previews: some View {
        QRSMSView()
    }
}

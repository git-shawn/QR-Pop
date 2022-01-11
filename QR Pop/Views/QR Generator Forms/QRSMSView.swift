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
    
    private func setCodeContent() {
        let content = "smsto:\(qrCode.formStates[0]):\(qrCode.formStates[1])"
        qrCode.setContent(string: content)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            TextField("Enter Phone Number", text: $qrCode.formStates[0])
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.phonePad)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onChange(of: qrCode.formStates[0], perform: {_ in
                    setCodeContent()
                })

            TextEditorModal(showTextEditor: $showTextModal, text: $qrCode.formStates[1])
                .onChange(of: showTextModal) {_ in
                    setCodeContent()
                }
        }
    }
}

struct QRSMSView_Previews: PreviewProvider {
    static var previews: some View {
        QRSMSView()
    }
}

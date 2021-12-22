//
//  QRSMSView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRSMSView: View {
    @EnvironmentObject var qrCode: QRCode

    @State private var text: String = ""
    
    var body: some View {
        VStack(alignment: .center) {
            TextField("Enter Phone Number", text: $text)
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.phonePad)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onChange(of: text) { value in
                    qrCode.setContent(string: "sms:"+text)
                }
        }.onChange(of: qrCode.codeContent, perform: {value in
            if (value.isEmpty) {
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

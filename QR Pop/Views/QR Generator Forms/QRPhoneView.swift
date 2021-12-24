//
//  QRPhoneView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRPhoneView: View {
    @EnvironmentObject var qrCode: QRCode

    @State private var text: String = ""
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            TextField("Enter Phone Number", text: $text)
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.phonePad)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onChange(of: text) { value in
                    qrCode.setContent(string: "tel:"+text)
                }
        }.onChange(of: qrCode.codeContent, perform: {value in
            if (value.isEmpty) {
                text = ""
            }
        })
    }
}

struct QRPhoneView_Previews: PreviewProvider {
    static var previews: some View {
        QRPhoneView()
    }
}

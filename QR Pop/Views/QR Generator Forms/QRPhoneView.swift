//
//  QRPhoneView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRPhoneView: View {
    @EnvironmentObject var qrCode: QRCode
    
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
        }.onChange(of: qrCode.formStates, perform: {_ in
            qrCode.setContent(string: qrCode.formStates[0])
        })
    }
}

struct QRPhoneView_Previews: PreviewProvider {
    static var previews: some View {
        QRPhoneView()
    }
}

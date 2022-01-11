//
//  QRLinkView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRLinkView: View {
    @EnvironmentObject var qrCode: QRCode
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            TextField("Enter URL", text: $qrCode.formStates[0])
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onChange(of: qrCode.formStates) { _ in
                    qrCode.setContent(string: qrCode.formStates[0])
                }
        }
    }
}

struct QRLinkView_Previews: PreviewProvider {
    static var previews: some View {
        QRLinkView()
    }
}

//
//  QRLinkView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRLinkView: View {
    @EnvironmentObject var qrCode: QRCode
    
    @State private var text: String = ""
    
    var body: some View {
        VStack(alignment: .center) {
            TextField("Enter URL", text: $text)
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onChange(of: text) { value in
                    qrCode.setContent(string: value)
                }
        }.onChange(of: qrCode.codeContent, perform: {value in
            if (value.isEmpty) {
                text = ""
            }
        })
    }
}

struct QRLinkView_Previews: PreviewProvider {
    static var previews: some View {
        QRLinkView()
    }
}

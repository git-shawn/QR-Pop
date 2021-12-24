//
//  QRCryptoView.swift
//  QR Pop
//
//  Created by Shawn Davis on 12/23/21.
//

import SwiftUI

struct QRCryptoView: View {
    @EnvironmentObject var qrCode: QRCode
    
    @State private var text: String = ""
    @State private var amount: String = ""
    @State private var prefix: String = "bitcoin"
    
    private func setCodeContent() {
        var content: String
        if (amount.isEmpty) {
            content = "\(prefix):\(text)"
        } else {
            content = "\(prefix):\(text)?amount\(amount)"
        }
        qrCode.setContent(string: content)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack {
                #if os(iOS)
                Text("Cryptocurrency Type")
                Spacer()
                #endif
                Picker("Cryptocurrency Type", selection: $prefix) {
                    Text("Bitcoin").tag("bitcoin")
                    Text("Ethereum").tag("ethereum")
                    Text("Bitcoin Cash").tag("bitcoincash")
                    Text("Litecoin").tag("litecoin")
                }.help("The kind of cryptocurrency to request when scanned.")
                    #if os(iOS)
                    .pickerStyle(.menu)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 15)
                    .background(Color("ButtonBkg"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .animation(.interactiveSpring(), value: prefix)
                    #endif
                    .onChange(of: prefix) {_ in
                        setCodeContent()
                    }
            }.padding(.horizontal, 15)
            
            TextField("Public Wallet Address", text: $text)
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.twitter)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onChange(of: text) {_ in
                    setCodeContent()
                }
                .help("The address of the wallet the scanner should send cryptocurrency to.")
            
            TextField("Amount", text: $amount)
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.numberPad)
            #endif
                .onChange(of: amount) {_ in
                    setCodeContent()
                }
                .help("The amount of cryptocurrency to send.")
        }.onChange(of: qrCode.codeContent, perform: {value in
            if (value.isEmpty) {
                text = ""
                amount = ""
                prefix = "bitcoin"
            }
        })
    }
}

struct QRCryptoView_Previews: PreviewProvider {
    static var previews: some View {
        QRCryptoView()
    }
}

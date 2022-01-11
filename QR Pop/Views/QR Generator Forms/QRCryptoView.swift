//
//  QRCryptoView.swift
//  QR Pop
//
//  Created by Shawn Davis on 12/23/21.
//

import SwiftUI

struct QRCryptoView: View {
    @EnvironmentObject var qrCode: QRCode
    
    private func setCodeContent() {
        var content: String
        if (qrCode.formStates[2].isEmpty) {
            content = "\(qrCode.formStates[0]):\(qrCode.formStates[1])"
        } else {
            content = "\(qrCode.formStates[0]):\(qrCode.formStates[1])?amount\(qrCode.formStates[2])"
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
                Picker("Cryptocurrency Type", selection: $qrCode.formStates[0]) {
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
                    #endif
            }.padding(.horizontal, 15)
            
            TextField("Public Wallet Address", text: $qrCode.formStates[1])
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.twitter)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .help("The address of the wallet the scanner should send cryptocurrency to.")
            
            TextField("Amount", text: $qrCode.formStates[2])
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.numberPad)
            #endif
                .help("The amount of cryptocurrency to send.")
            
        }.onChange(of: qrCode.formStates, perform: {_ in
            setCodeContent()
        })
        .onAppear(perform: {
            if qrCode.formStates[0].isEmpty {
                qrCode.formStates[0] = "bitcoin"
            }
        })
    }
}

struct QRCryptoView_Previews: PreviewProvider {
    static var previews: some View {
        QRCryptoView()
    }
}

//
//  QRWifiView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRWifiView: View {
    @EnvironmentObject var qrCode: QRCode

    /// Create the QR code.
    private func setCodeContent() {
        let text = "WIFI:T:\(qrCode.formStates[0]);S:\(qrCode.formStates[1]);P:\(qrCode.formStates[2]);;"
        qrCode.setContent(string: text)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Group {
                #if os(macOS)
                GetWifiButton()
                    .environmentObject(qrCode)
                #endif
                Picker("Wifi Authentication Method", selection: $qrCode.formStates[0]) {
                    Text("WPA").tag("WPA")
                    Text("WEP").tag("WEP")
                }
                .help("The encryption method for the Wifi network. If you don't know, try WPA.")
                #if os(iOS)
                    .pickerStyle(.segmented)
                #endif
                    .padding()
                
                //Accept SSID to generate QR code from
                TextField("Enter Wifi SSID", text: $qrCode.formStates[1])
                    .help("The public name of a Wifi network.")
                    .textFieldStyle(QRPopTextStyle())
                #if os(iOS)
                    .autocapitalization(.none)
                    .submitLabel(.done)
                #endif
                    .disableAutocorrection(true)
                
                //Accept Wifi Password to generate QR code from
                SecureField("Enter Wifi Password", text: $qrCode.formStates[2])
                    .textFieldStyle(QRPopTextStyle())
                #if os(iOS)
                    .autocapitalization(.none)
                    .submitLabel(.done)
                #endif
                    .disableAutocorrection(true)
            }
        }.onChange(of: qrCode.formStates) {_ in
            setCodeContent()
        }
        .onAppear(perform: {
            if qrCode.formStates[0].isEmpty {
                qrCode.formStates[0] = "WPA"
            }
        })
    }
}

struct QRWifiView_Previews: PreviewProvider {
    static var previews: some View {
        QRWifiView()
    }
}

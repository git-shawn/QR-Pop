//
//  QRWifiView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRWifiView: View {
    @EnvironmentObject var qrCode: QRCode

    @State private var text = "WIFI:T:;S:;P:;;"
    @State private var ssid = ""
    @State private var pass = ""
    @State private var auth = "WPA"

    /// Create the QR code.
    private func setCodeContent() {
        text = "WIFI:T:\(auth);S:\(ssid);P:\(pass);;"
        qrCode.setContent(string: text)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Group {
                #if os(macOS)
                GetWifiButton()
                    .environmentObject(qrCode)
                #endif
                
                Picker("Wifi Authentication Method", selection: $auth) {
                    Text("WPA").tag("WPA")
                    Text("WEP").tag("WEP")
                }
                .help("The encryption method for the Wifi network. If you don't know, try WPA.")
                #if os(iOS)
                    .pickerStyle(.segmented)
                #endif
                    .padding()
                    .onChange(of: auth) {_ in
                        setCodeContent()
                    }
                
                //Accept SSID to generate QR code from
                TextField("Enter Wifi SSID", text: $ssid)
                    .help("The public name of a Wifi network.")
                    .textFieldStyle(QRPopTextStyle())
                #if os(iOS)
                    .autocapitalization(.none)
                    .submitLabel(.done)
                #endif
                    .disableAutocorrection(true)
                    .onChange(of: ssid) {_ in
                        setCodeContent()
                    }
                
                //Accept Wifi Password to generate QR code from
                SecureField("Enter Wifi Password", text: $pass)
                    .textFieldStyle(QRPopTextStyle())
                #if os(iOS)
                    .autocapitalization(.none)
                    .submitLabel(.done)
                #endif
                    .disableAutocorrection(true)
                    .onChange(of: pass) {_ in
                        setCodeContent()
                    }
            }
        }.onChange(of: qrCode.codeContent, perform: {value in
            if (value.isEmpty) {
                text = "WIFI:T:;S:;P:;;"
                ssid = ""
                pass = ""
                auth = "WPA"
            }
        })
    }
}

struct QRWifiView_Previews: PreviewProvider {
    static var previews: some View {
        QRWifiView()
    }
}

//
//  QRWifiView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRWifiView: View {
    @State private var qrData: Data
    @State private var bgColor: Color = .white
    @State private var fgColor: Color = .black
    private let qrCode = QRCode()
    #if os(macOS)
    @State private var showDesignPopover: Bool = false
    #endif
    
    //Unique variables for wifi
    @State private var text = "WIFI:T:;S:;P:;;"
    @State private var ssid = ""
    @State private var pass = ""
    @State private var auth = "WPA"
    @State private var showHelp = false
    
    init() {
        qrData = qrCode.generate(content: "WIFI:T:;S:;P:;;", fg: .black, bg: .white)
    }
    
    var body: some View {
        ScrollView {
            QRImage(qrCode: $qrData, bg: $bgColor, fg: $fgColor)
                .padding()
            
            Group {
                Picker("Wifi Authentication Method", selection: $auth) {
                    Text("WPA").tag("WPA")
                    Text("WEP").tag("WEP")
                }
                #if os(iOS)
                    .pickerStyle(.segmented)
                #endif
                    .padding()
                    .onChange(of: auth) { value in
                        text = "WIFI:T:\(auth);S:\(ssid);P:\(pass);;"
                        qrData = qrCode.generate(content: text, fg: fgColor, bg: bgColor)
                    }
                
                //Accept SSID to generate QR code from
                TextField("Enter Wifi SSID", text: $ssid)
                    .textFieldStyle(QRPopTextStyle())
                #if os(iOS)
                    .autocapitalization(.none)
                    .submitLabel(.done)
                #endif
                    .disableAutocorrection(true)
                    .onChange(of: ssid) { value in
                        text = "WIFI:T:\(auth);S:\(ssid);P:\(pass);;"
                        qrData = qrCode.generate(content: text, fg: fgColor, bg: bgColor)
                    }
                
                //Accept Wifi Password to generate QR code from
                SecureField("Enter Wifi Password", text: $pass)
                    .textFieldStyle(QRPopTextStyle())
                #if os(iOS)
                    .autocapitalization(.none)
                    .submitLabel(.done)
                #endif
                    .disableAutocorrection(true)
                    .onChange(of: pass) { value in
                        text = "WIFI:T:\(auth);S:\(ssid);P:\(pass);;"
                        qrData = qrCode.generate(content: text, fg: fgColor, bg: bgColor)
                    }
            }
            
            #if os(iOS)
            QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
            .onChange(of: [bgColor, fgColor]) { value in
                qrData = qrCode.generate(content: text, fg: fgColor, bg: bgColor)
            }
            #endif
        }.navigationTitle("Wifi Generator")
        .sheet(isPresented: $showHelp, content: {
            WifiHelpModal(isPresented: $showHelp)
        })
        .toolbar(content: {
            HStack{
                Button(
                action: {
                    showHelp.toggle()
                }) {
                    Label("Help", systemImage: "questionmark.circle")
                        .labelStyle(.iconOnly)
                }
                #if os(macOS)
                Button(
                action: {
                    showDesignPopover.toggle()
                }){
                    Image(systemName: "paintpalette")
                }
                .popover(isPresented: $showDesignPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                    QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
                    .onChange(of: [bgColor, fgColor]) { value in
                        qrData = qrCode.generate(content: text, fg: fgColor, bg: bgColor)
                    }.frame(minWidth: 300)
                }
                #endif
                Button(
                action: {
                    text = "WIFI:T:;S:;P:;;"
                    ssid = ""
                    pass = ""
                    auth = "WPA"
                    fgColor = .black
                    bgColor = .white
                    qrData = qrCode.generate(content: "WIFI:T:;S:;P:;;", fg: .black, bg: .white)
                }){
                    Image(systemName: "trash")
                }
                #if os(macOS)
                SaveButton(qrCode: qrData)
                #endif
                ShareButton(shareContent: [qrData.image], buttonTitle: "Share")
            }
        })
    }
}

private struct WifiHelpModal: View {
    @Binding var isPresented: Bool
    var body: some View {
        ModalNavbar(navigationTitle: "Wifi Help", showModal: $isPresented) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("How do I Make a Wifi QR Code?")
                            .font(.largeTitle)
                            .bold()
                    Group {
                        Text("What is an SSID?")
                            .font(.headline)
                        Text("The SSID, or Service Set Identifier, is just the name of your network. Think, for example, \"Public Library Free Wifi.\" Just type it in, exactly as it appears.")
                        Text("What is WPA/WEP?")
                            .font(.headline)
                        Text("These are authentication methods that help you, and your guests, securely connect to your network. Your code needs to know which method your router uses so that it can help the scanner's device automatically connect. If you aren't sure which method you use, consider trying WPA first. Most routers connect via WPA, so it's a safe bet!\n\nNote: QR Pop does not support unsecured Wifi networks or enterprise networks.")
                        Text("Is it safe to enter my Wifi password?")
                            .font(.headline)
                        Text("100%\n\nAll codes are generated on your device, and QR Pop never connects to a server. QR Pop disguises your password when you type it with bullets to ward off prying eyes, but understand that information isn't actually leaving your device in any way.")
                        Text("Wait, how does Wifi even work?")
                            .font(.headline)
                        Text("Oh man who knows...")
                    }
                }.padding()
            }
        }
    }
}

struct QRWifiView_Previews: PreviewProvider {
    static var previews: some View {
        QRWifiView()
    }
}

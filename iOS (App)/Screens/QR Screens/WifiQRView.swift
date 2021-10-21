//
//  WifiQRView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/17/21.
//

import SwiftUI
import UniformTypeIdentifiers

struct WifiQRView: View {
    let qrCode = QRCode()
    let imageSaver = ImageSaver()
    
    //QR View standard variables
    @State private var bgColor = Color.white
    @State private var fgColor = Color.black
    @State private var showShare = false
    @State private var content: Data?
    
    //Unique variables for wifi
    @State private var ssid = ""
    @State private var pass = ""
    @State private var auth = QRCode.wifiAuthType.WPA
    @State private var showHelp = false
    
    init() {
        _content = State(initialValue: QRCode().generate(content: "", bg: .white, fg: .black))
    }
    
    /// Generate a QR code from a URL
    var body: some View {
        ScrollView {
            VStack() {
                
                QRImageView(content: $content, share: $showShare, bg: $bgColor)
                
                Group {
                    Picker("Wifi Authentication Method", selection: $auth) {
                        Text("WPA").tag(QRCode.wifiAuthType.WPA)
                        Text("WEP").tag(QRCode.wifiAuthType.WEP)
                    }
                        .pickerStyle(.segmented)
                        .padding()
                        .onChange(of: auth) { value in
                            content = qrCode.generateWifi(auth: auth, ssid: ssid, password: pass, bg: bgColor, fg: fgColor)
                        }
                    
                    //Accept SSID to generate QR code from
                    TextField("Enter Wifi SSID", text: $ssid)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .autocapitalization(.none)
                        .submitLabel(.done)
                        .disableAutocorrection(true)
                        .onChange(of: ssid) { value in
                            content = qrCode.generateWifi(auth: auth, ssid: ssid, password: pass, bg: bgColor, fg: fgColor)
                        }
                    Divider()
                        .padding(.leading)
                    
                    //Accept Wifi Password to generate QR code from
                    SecureField("Enter Wifi Password", text: $pass)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .autocapitalization(.none)
                        .submitLabel(.done)
                        .disableAutocorrection(true)
                        .onChange(of: pass) { value in
                            content = qrCode.generateWifi(auth: auth, ssid: ssid, password: pass, bg: bgColor, fg: fgColor)
                        }
                    Divider()
                        .padding(.bottom)
                        .padding(.leading)
                }
                
                QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
                .onChange(of: [bgColor, fgColor]) { value in
                    content = qrCode.generateWifi(auth: auth, ssid: ssid, password: pass, bg: bgColor, fg: fgColor)
                }
            }.padding(.top)
        }.navigationBarTitle(Text("WiFi QR Code"), displayMode: .large)
        .toolbar(content: {
            HStack{
                Button(
                action: {
                    showHelp = true
                }){
                    Image(systemName: "questionmark.circle")
                }.sheet(isPresented: $showHelp, content: {
                    WifiQRHelpModal()
                })
                Button(
                action: {
                    showShareSheet(with: [UIImage(data: content!)!])
                }){
                    Image(systemName: "square.and.arrow.up")
                }
            }
        })
    }
}

struct WifiQRView_Previews: PreviewProvider {
    static var previews: some View {
        WifiQRView()
    }
}

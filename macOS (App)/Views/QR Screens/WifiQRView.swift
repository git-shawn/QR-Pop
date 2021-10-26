//
//  WifiQRView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/23/21.
//

import SwiftUI

struct WifiQRView: View {
    
    // Standard QR Screen states
    @State private var image: NSImage
    @State private var bgColor: Color = Color.white
    @State private var fgColor: Color = Color.black
    @State private var isSharing: Bool = false
    let qrCode = QRCode()
    
    init() {
        self.image = QRCode().generate(content: "", fg: .black, bg: .white)
    }
    
    // QR states
    @State private var ssid: String = ""
    @State private var pass: String = ""
    @State private var auth: QRCode.wifiAuthType = .WPA
    @State private var showAuthPopover: Bool = false
    @State private var showSSIDPopover: Bool = false
    
    var body: some View {
        ScrollView {
            HStack(alignment: .center, spacing: 20) {
                QRImage(qrCode: $image, bg: $bgColor)
                
                QRDesignPanel(bg: $bgColor, fg: $fgColor)
                .onChange(of: [bgColor, fgColor], perform: {_ in
                    image = qrCode.generateWifi(auth: auth, ssid: ssid, password: pass, bg: bgColor, fg: fgColor)
                })
            }.padding()
            
            HStack {
                Picker("Wifi Authentication Method", selection: $auth) {
                    Text("WPA").tag(QRCode.wifiAuthType.WPA)
                    Text("WEP").tag(QRCode.wifiAuthType.WEP)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: auth) { value in
                    image = qrCode.generateWifi(auth: value, ssid: ssid, password: pass, bg: bgColor, fg: fgColor)
                }
                Button(action: {
                    showAuthPopover = true
                }) {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.accentColor)
                }.popover(
                    isPresented: self.$showAuthPopover,
                    arrowEdge: .bottom
                ) {
                    VStack(alignment: .leading) {
                        Text("What is a \"Wifi Authentication Method\"?")
                            .font(.headline)
                        Text("The short of it is that these acronyms represent security protocols that help keep your information safe. Wifi QR codes are different depending on the protocol, so we need to know the right one first.\n\nIt's easy to figure out what method your network is using. On your Mac, open your System Preferences then select \"Network\". Then, in the bottom right-hand corner you'll select \"Advanced\". This sould create a list of your \"Preferred Networks\" with their Security Method listed next to their names.")
                    }.padding()
                    .frame(width: 300)
                }
                .buttonStyle(PlainButtonStyle())
            }.padding(.bottom)
            .frame(maxWidth: 500)
            HStack {
                TextField("Enter SSID", text: $ssid)
                    .textFieldStyle(QRPopTextViewStyle())
                    .disableAutocorrection(true)
                    .onChange(of: ssid, perform: { value in
                        image = qrCode.generateWifi(auth: auth, ssid: value, password: pass, bg: bgColor, fg: fgColor)
                    })
                Button(action: {
                    showSSIDPopover = true
                }) {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.accentColor)
                }.popover(
                    isPresented: self.$showSSIDPopover,
                    arrowEdge: .bottom
                ) {
                    VStack(alignment: .leading) {
                        Text("What is an \"SSID\"?")
                            .font(.headline)
                        Text("A network's SSID is just it's name. Type the name you see when you usually connect to your wifi network exactly how it appears.")
                    }.padding()
                    .frame(width: 300)
                }
                .buttonStyle(PlainButtonStyle())
            }.padding(.bottom)
            .frame(maxWidth: 500)
            SecureField("Enter WiFi Password", text: $pass)
                .textFieldStyle(QRPopTextViewStyle())
                .disableAutocorrection(true)
                .frame(maxWidth: 500)
                .padding(.horizontal)
                .padding(.bottom)
                .onChange(of: pass, perform: { value in
                    image = qrCode.generateWifi(auth: auth, ssid: ssid, password: value, bg: bgColor, fg: fgColor)
                })
            
        }.navigationTitle("WiFi QR Generator")
        .toolbar {
            HStack {
                Button(action: {
                    ssid = ""
                    pass = ""
                    auth = .WPA
                    bgColor = .white
                    fgColor = .black
                }) {
                    Image(systemName: "trash")
                }.accessibilityHint("Erase QR Code")
                .help("Erase QR Code")
                Divider()
                Button(action: {
                    ImageSaver().save(image: image)
                }) {
                    Image(systemName: "square.and.arrow.down")
                }.accessibilityLabel("Save")
                .accessibilityHint("Save QR Code")
                .help("Save QR Code")
                Button(action: {
                    isSharing = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                    .accessibilityHint("Share QR Code")
                    .help("Share QR Code")
                    .background(SharePicker(isPresented: $isSharing, sharingItems: [image]))
                }
            }
        }
    }
}

struct WifiQRView_Previews: PreviewProvider {
    static var previews: some View {
        WifiQRView()
    }
}

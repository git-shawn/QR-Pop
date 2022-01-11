//
//  SafariExtensionSettingsView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/24/21.
//
import SwiftUI
import Preferences

struct SafariExtensionSettingsView: View {
    // Safari Extension QR Code width & height in pixels
    @AppStorage("codeSize", store: UserDefaults(suiteName: ("\(Bundle.main.infoDictionary!["AppIdentifierPrefix"] as! String)shwndvs.QR-Pop"))) var codeSize: Int = 190
    
    // Safari Extension hostname visible or not
    @AppStorage("urlToggle", store: UserDefaults(suiteName: ("\(Bundle.main.infoDictionary!["AppIdentifierPrefix"] as! String)shwndvs.QR-Pop"))) var urlToggle: Bool = false
    
    // Safari Extension UTM removal on or off
    @AppStorage("referralToggle", store: UserDefaults(suiteName: ("\(Bundle.main.infoDictionary!["AppIdentifierPrefix"] as! String)shwndvs.QR-Pop"))) var referralToggle: Bool = false
    
    // Safari Extension QR Code background and foreground colors as hex codes.
    @AppStorage("extBgColor", store: UserDefaults(suiteName: ("\(Bundle.main.infoDictionary!["AppIdentifierPrefix"] as! String)shwndvs.QR-Pop"))) var extHexBg: String = "#FFFFFF"
    @AppStorage("extFgColor", store: UserDefaults(suiteName: ("\(Bundle.main.infoDictionary!["AppIdentifierPrefix"] as! String)shwndvs.QR-Pop"))) var extHexFg: String = "#000000"
    
    @State var extBgColor: Color = .white
    @State var extFgColor: Color = .black
    
    var body: some View {
        Preferences.Container(contentWidth: 300) {
            Preferences.Section(title: "QR Code Size") {
                Preferences.Section(title: "") {
                    Picker("", selection: $codeSize) {
                        Text("Small").tag(100)
                        Text("Medium").tag(190)
                        Text("Large").tag(240)
                        Text("Extra Large").tag(300)
                    }.frame(width: 120.0)
                }
            }
            Preferences.Section(title:"Show Webpage URL") {
                Preferences.Section(title:"") {
                    Toggle("", isOn: $urlToggle)
                        .toggleStyle(SwitchToggleStyle())
                        .labelsHidden()
                }
            }
            Preferences.Section(title:"Remove Tracking Codes") {
                Preferences.Section(title:""){
                    Toggle("", isOn: $referralToggle)
                    .toggleStyle(SwitchToggleStyle())
                    .labelsHidden()
                    .help("Strip UTM tracking parameters from a link before generating a QR code.")
                }
            }
            Preferences.Section(title:"Background Color") {
                Preferences.Section(title:""){
                    ColorPicker("Background Color", selection: $extBgColor)
                    .labelsHidden()
                    .onChange(of: extBgColor, perform: {color in
                        let hex = color.toHex()
                        extHexBg = hex
                    })
                }
            }
            Preferences.Section(title:"Background Color") {
                Preferences.Section(title:""){
                    ColorPicker("Foreground Color", selection: $extFgColor)
                    .labelsHidden()
                    .onChange(of: extFgColor, perform: {color in
                        let hex = color.toHex()
                        extHexFg = hex
                    })
                }
            }
        }.onAppear(perform: {
            extBgColor = Color(hex: extHexBg)
            extFgColor = Color(hex: extHexFg)
        })
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String {
        let components = cgColor?.components
        let r = Int(components![0]*255)
        let g = Int(components![1]*255)
        let b = Int(components![2]*255)
        let rgb:Int = (Int)(r)<<16 | (Int)(g)<<8 | (Int)(b)<<0
        return String(format: "#%06x", rgb)
    }
}

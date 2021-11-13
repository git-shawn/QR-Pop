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
        }
    }
}

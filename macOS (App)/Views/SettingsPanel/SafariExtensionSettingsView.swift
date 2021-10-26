//
//  SafariExtensionSettingsView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/24/21.
//

import SwiftUI
import Preferences

struct SafariExtensionSettingsView: View {
    
    @AppStorage("codeSize", store: UserDefaults(suiteName: (Bundle.main.infoDictionary!["TeamIdentifierPrefix"] as! String))) var codeSize: Int = 190
    
    @AppStorage("urlToggle", store: UserDefaults(suiteName: (Bundle.main.infoDictionary!["TeamIdentifierPrefix"] as! String))) var urlToggle: Bool = true
    
    @AppStorage("referralToggle", store: UserDefaults(suiteName: (Bundle.main.infoDictionary!["TeamIdentifierPrefix"] as! String))) var referralToggle: Bool = false
    
    var body: some View {
        Preferences.Container(contentWidth: 300) {
            Preferences.Section(title: "QR Code Size:") {
                Preferences.Section(title: "") {
                    Stepper(value: $codeSize, in: 100...300, step: 10) {
                        Text("\(codeSize)px")
                    }
                }
            }
            Preferences.Section(title:"Show Webpage URL:") {
                Preferences.Section(title:"") {
                    Toggle("", isOn: $urlToggle)
                        .toggleStyle(SwitchToggleStyle())
                        .labelsHidden()
                }
            }
            Preferences.Section(title:"Remove Tracking Codes:") {
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

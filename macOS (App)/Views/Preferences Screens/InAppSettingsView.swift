//
//  InAppSettingsView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/24/21.
//

import SwiftUI
import Preferences

struct InAppSettingsView: View {
    
    @AppStorage("autoPasteLinks", store: UserDefaults(suiteName: (Bundle.main.infoDictionary!["TeamIdentifierPrefix"] as! String))) var autoPasteLinks: Bool = false
    
    @AppStorage("errorLevel") var errorLevel: Int = 0
    
    var body: some View {
        Preferences.Container(contentWidth: 300) {
            Preferences.Section(title: "Create Codes from Clipboard:") {
                Preferences.Section(title: "") {
                    Toggle("", isOn: $autoPasteLinks)
                        .toggleStyle(SwitchToggleStyle())
                        .labelsHidden()
                        .help("Create QR codes from a URL you copied automatically.")
                }
            }
            Preferences.Section(title: "Error Correction Level:") {
                Preferences.Section(title: "") {
                    Picker("", selection: $errorLevel) {
                        Text("7%").tag(0)
                        Text("15%").tag(1)
                        Text("25%").tag(2)
                        Text("30%").tag(3)
                    }.frame(width: 120.0)
                    .padding(.leading, -5)
                    .help("Select a correction level to generate QR codes at. A higher level creates more durable, but complicated, codes.")
                }
            }
        }
    }
}

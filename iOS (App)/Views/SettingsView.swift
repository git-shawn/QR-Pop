//
//  SettingsView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/9/21.
//

import SwiftUI

struct SettingsView: View {
    
    // Safari Extension QR Code width & height in pixels
    @AppStorage("codeSize", store: UserDefaults(suiteName: "group.shwndvs.qr-pop")) var codeSize: Int = 190
    
    // Safari Extension hostname visible or not
    @AppStorage("urlToggle", store: UserDefaults(suiteName: "group.shwndvs.qr-pop")) var urlToggle: Bool = false
    
    // Safari Extension UTM removal on or off
    @AppStorage("referralToggle", store: UserDefaults(suiteName: "group.shwndvs.qr-pop")) var referralToggle: Bool = false
    
    var body: some View {
        List {
            Section("Safari Extension") {
                HStack {
                    Spacer()
                    Image(systemName: "qrcode")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(width: CGFloat(codeSize), height: CGFloat(codeSize))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.primary, lineWidth: 4)
                        )
                    Spacer()
                }.frame(height: 340)
                
                // Range from 100 to 300, incrementing by 10
                Stepper(value: $codeSize, in: 100...300, step: 10) {
                    Text("QR Code Size")
                }
                
                // Toggle showing hostname in Safari Extension
                Toggle("Show Webpage URL", isOn: $urlToggle)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                
                VStack(alignment:.leading) {
                    Toggle("Remove tracking codes", isOn: $referralToggle)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                    Text("Links may sometimes include UTM tracking parameters. These can make the link longer, and the QR codes QR Pop generates more complex.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            if UIApplication.shared.supportsAlternateIcons {
                Section("Appearance") {
                    NavigationLink(destination: AltIconView()) {
                        Label("App Icon", systemImage: "app.badge.checkmark")
                    }
                }
            }
        }.navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

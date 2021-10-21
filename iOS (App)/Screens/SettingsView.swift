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
    
    // Safari Extension UTM removal on or off
    @AppStorage("errorCorrection") var errorLevel: Int = 0
    
    @Binding var shown: Bool
    
    var body: some View {
        NavigationView {
            Form {
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
                    
                    VStack(alignment:.leading, spacing: 5) {
                        Toggle("Remove tracking codes", isOn: $referralToggle)
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                        Text("Links may sometimes include UTM tracking parameters. These can make the link longer, and the QR codes QR Pop generates more complex.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                Section("QR Pop App") {
                    VStack(alignment: .leading, spacing:5) {
                        Picker("Error Correction Level", selection: $errorLevel) {
                            Text("7%").tag(0)
                            Text("15%").tag(1)
                            Text("25%").tag(2)
                            Text("30%").tag(3)
                        }
                        Text("A higher error correction level will make a QR code more durable, but also more complex. Some codes may even become too complex to scan.")
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        shown = false
                        
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color(UIColor.secondaryLabel), Color(UIColor.systemFill))
                            .font(.title2)
                            .accessibility(label: Text("Close"))
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static var show = true
    static var previews: some View {
        SettingsView(shown: $show)
    }
}

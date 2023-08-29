//
//  SettingsView.swift
//  QR Pop
//
//  Created by Shawn Davis on 8/13/23.
//
#if os(iOS)
import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            AppearanceSettings()
            DataSettings()
            SupportSettings()
            AboutSettings()
            
            // Version Information & Footer
            Section {
                LabeledContent("Version", value: "\(Constants.releaseVersionNumber) (\(Constants.buildVersionNumber))")
            }
            
            Section(content: {}, footer: {
                VStack {
                    Text("QR Code is a registered trademark of [DENSO WAVE](https://www.qrcode.com/en/)")
                    Text("Made with \(Image(systemName: "heart")) in Southern Illinois")
                }
                .frame(maxWidth: .infinity)
                .font(.caption2)
                .foregroundColor(.secondary)
            })
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif

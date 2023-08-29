//
//  AppearanceSettings.swift
//  QR Pop
//
//  Created by Shawn Davis on 8/13/23.
//
#if os(iOS)
import SwiftUI

struct AppearanceSettings: View {
    var body: some View {
        Section("Appearance") {
            NavigationLink(destination: {
                AppIconView()
            }, label: {
                Label("Change app icon", image: "qrpop.icon")
            })
        }
    }
}

struct AppearanceSettings_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSettings()
    }
}
#endif

//
//  SettingsMenu.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/15/23.
//
#if os(macOS)
import SwiftUI

struct SettingsMenu: View {
    @StateObject private var sceneModel = SceneModel()
    
    var body: some View {
        TabView {
            Form {
                DataSettings()
            }
                .toast($sceneModel.toaster)
                .tabItem({
                    Label("Data", systemImage: "internaldrive")
                })
            Form {
                SupportSettings()
            }
                .toast($sceneModel.toaster)
                .tabItem({
                    Label("Support", systemImage: "lifepreserver")
                })
            Form {
                AboutSettings()
            }
                .toast($sceneModel.toaster)
                .tabItem({
                    Label("About", systemImage: "hand.wave")
                })
        }
        .environmentObject(sceneModel)
        .buttonStyle(.plain)
        .labelStyle(StandardButtonLabelStyle())
        .formStyle(.grouped)
        .frame(minWidth: 400, minHeight: 300)
    }
}

struct SettingsMenu_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenu()
    }
}
#endif

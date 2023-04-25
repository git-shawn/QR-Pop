//
//  SettingsMenu.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/15/23.
//

import SwiftUI

struct SettingsMenu: View {
    @StateObject private var sceneModel = SceneModel()
    var body: some View {
        TabView {
            SettingsView()
                .environmentObject(sceneModel)
                .toast($sceneModel.toaster)
                .tabItem({
                    Label("Settings", systemImage: "gearshape")
                })
        }
    }
}

struct SettingsMenu_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenu()
    }
}

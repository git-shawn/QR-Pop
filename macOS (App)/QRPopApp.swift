//
//  QRPopApp.swift
//  macOS (App)
//
//  Created by Shawn Davis on 9/21/21.
//

import SwiftUI

@main
struct QRPopApp: App {
    @Environment(\.openURL) var openURL
    
    var body: some Scene {
        WindowGroup {
            MainContentView()
        }.commands {
            SidebarCommands()
            CommandGroup(replacing: .help) {
                NavigationLink(destination: TipsView()) {
                    Text("Help")
                }
                NavigationLink(destination: PrivacyView()) {
                    Text("Privacy Policy")
                }
            }
            CommandGroup(replacing: CommandGroupPlacement.appSettings) {
                NavigationLink(destination: PreferencesView()) {
                    Text("Preferences")
                }
            }
        }
    }
}


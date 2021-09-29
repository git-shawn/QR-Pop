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
            CommandGroup(replacing: .help) {
                Button(action: {openURL(URL(string: "https://qr-pop.glitch.me/#support")!)}) {
                    Text("QR Pop Help")
                }
            }
        }
    }
}


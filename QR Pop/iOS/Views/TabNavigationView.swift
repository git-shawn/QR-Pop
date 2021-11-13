//
//  TabView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/29/21.
//

import SwiftUI

struct TabNavigationView: View {
    var body: some View {
        TabView {
            NavigationView {
                QRView()
            }
            .tag(0)
            .tabItem {
                Image(systemName: "qrcode")
                Text("Generator")
            }
            NavigationView {
                ExtensionGuideView()
            }
                .tag(1)
                .tabItem {
                    Image(systemName: "puzzlepiece.extension")
                    Text("Guides")
                }
            NavigationView {
                SettingsView()
            }
                .tag(2)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
    }
}

struct TabNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        TabNavigationView()
    }
}

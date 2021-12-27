//
//  TabView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/29/21.
//

import SwiftUI

struct TabNavigationView: View {
    @State private var tabSelection = 0
    
    var body: some View {
        TabView(selection: $tabSelection) {
            NavigationView {
                QRView()
            }
            .tag(0)
            .tabItem {
                Image(systemName: "qrcode")
                Text("Generator")
            }
            NavigationView {
                QRCameraView()
            }
            .tag(1)
            .tabItem {
                Image(systemName: "camera.on.rectangle")
                Text("Duplicate")
            }
            NavigationView {
                ExtensionGuideView()
            }
            .tag(2)
            .tabItem {
                Image(systemName: "puzzlepiece.extension")
                Text("Extensions")
            }
            NavigationView {
                SettingsView()
            }
            .tag(3)
            .tabItem {
                Image(systemName: "gearshape")
                Text("Settings")
            }
        }.onContinueUserActivity("shwndvs.QR-Pop.generator-selection", perform: {activity in
            tabSelection = 0
        })
    }
}

struct TabNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        TabNavigationView()
    }
}

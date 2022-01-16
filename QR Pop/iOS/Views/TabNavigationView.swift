//
//  TabView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/29/21.
//

import SwiftUI

struct TabNavigationView: View {
    @EnvironmentObject private var navController: NavigationController
    
    var body: some View {
        TabView(selection: $navController.activeRoute) {
            NavigationView {
                QRView()
            }
            .tag(Routes.generator)
            .tabItem {
                Image(systemName: "qrcode")
                Text("Generator")
            }
            NavigationView {
                QRCameraView()
            }
            .tag(Routes.duplicate)
            .tabItem {
                Image(systemName: "camera.on.rectangle")
                Text("Duplicate")
            }
            NavigationView {
                ExtensionGuideView()
            }
            .tag(Routes.extensions)
            .tabItem {
                Image(systemName: "puzzlepiece.extension")
                Text("Extensions")
            }
            NavigationView {
                SettingsView()
            }
            .tag(Routes.settings)
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

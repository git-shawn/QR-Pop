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
        TabView() {
            NavigationView {
                QRView()
            }
            .tag(Routes.generator)
            .tabItem {
                Image(systemName: "qrcode")
                Text("Create")
            }
            NavigationView {
                QRCameraView()
            }
            .tag(Routes.duplicate)
            .tabItem {
                Image(systemName: "qrcode.viewfinder")
                Text("Duplicate")
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

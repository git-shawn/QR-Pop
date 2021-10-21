//
//  Sidebar.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/19/21.
//

import SwiftUI

struct Sidebar: View {
    @State private var showSettings = false
    
    /// The Navigation Sidebar for QR Pop
    var body: some View {
        List {
            NavigationLink(destination: QRNavigationView()){
                Label {
                    Text("Make a QR Code")
                } icon: {
                    Image(systemName: "qrcode")
                }
            }.isDetailLink(false) //Makes QRNavigationView becomes the Sidebar
            NavigationLink(destination: GettingStartedView()) {
                Label {
                    Text("Enable Safari Extension")
                } icon: {
                    Image(systemName: "safari")
                }
            }
            NavigationLink(destination: ShareExtensionView()) {
                Label {
                    Text("Enable Share Sheet Action")
                } icon: {
                    Image(systemName: "square.and.arrow.up.on.square")
                }
            }
            NavigationLink(destination: AboutView()) {
                Label {
                    Text("About")
                } icon: {
                    Image(systemName: "info.circle")
                }
            }
        }.listStyle(SidebarListStyle())
        .navigationTitle("QR Pop")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showSettings = true
                    
                }) {
                    Image(systemName: "gear")
                        .accessibility(label: Text("Settings"))
                }
            }
        }.sheet(isPresented: $showSettings) {
            SettingsView(shown: $showSettings)
        }
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar()
    }
}

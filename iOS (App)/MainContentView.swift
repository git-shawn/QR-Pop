//
//  MainContentView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 9/25/21.
//

import SwiftUI

struct MainContentView: View {
    @State private var selectedRow: String?
    @State private var showSettingsSheet: Bool = false
    
    var body: some View {
        NavigationView {
            List() {
                Section() {
                    NavigationLink(destination: MakeQRView(), tag: "makeQR", selection: self.$selectedRow){
                        Label {
                            Text("Make a QR Code")
                        } icon: {
                            Image(systemName: "qrcode")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                NavigationLink(destination: GettingStartedView(), tag: "enableSafari", selection: self.$selectedRow) {
                    Label {
                        Text("Enable Safari Extension")
                    } icon: {
                        Image(systemName: "safari")
                            .foregroundColor(.red)
                    }
                }
                NavigationLink(destination: ShareExtensionView(), tag: "enableShare", selection: self.$selectedRow) {
                    Label {
                        Text("Enable Share Sheet Action")
                    } icon: {
                        Image(systemName: "square.and.arrow.up.on.square")
                            .foregroundColor(.purple)
                    }
                }
                NavigationLink(destination: AboutView(), tag: "about", selection: self.$selectedRow) {
                    Label {
                        Text("About")
                    } icon: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("QR Pop")
            .toolbar {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                        .accessibility(label: Text("Settings"))
                }
            }
            if UIDevice.current.userInterfaceIdiom == .pad {
                MakeQRView()
            }
        }.navigationViewStyle(.columns)
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
            .preferredColorScheme(.light)
            .previewInterfaceOrientation(.portrait)
    }
}

//
//  Sidebar.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/22/21.
//

import SwiftUI

struct Sidebar: View {
    @State var showSupportModal = false;
    var body: some View {
        List {
            Section(header: Text("Tools")) {
                NavigationLink(destination: QRNavigationView()) {
                    Label {
                        Text("Make a QR Code")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "qrcode")
                    }
                }
                NavigationLink(destination: GettingStartedView()) {
                    Label {
                        Text("Enable Extensions")
                            .foregroundColor(.primary)
                    } icon: {
                        if #available(macOS 12, *) {
                            Image(systemName: "puzzlepiece.extension")
                        } else {
                            Image("extensionSFMac")
                                .resizable()
                                .scaledToFit()
                                .padding(3)
                        }
                    }
                }
            }
            
            Section(header: Text("About")) {
                
                Link(destination: URL(string: "https://fromshawn.dev/qrpop.html")!) {
                    Label {
                        Text("Website")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "safari")
                    }
                }
                
                Link(destination: URL(string: "mailto:contact@fromshawn.dev")!) {
                    Label {
                        Text("Contact Me")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "envelope")
                    }
                }
                
                Link(destination: URL(string: "https://github.com/git-shawn/QR-Pop")!) {
                    Label {
                        Text("Source Code")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "doc.text")
                    }
                }
                
                NavigationLink(destination: PrivacyView()) {
                    Label {
                        Text("Privacy Policy")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "hand.raised")
                    }
                }
            }
        }.listStyle(SidebarListStyle())
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.leading")
                })
            }
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar()
    }
}

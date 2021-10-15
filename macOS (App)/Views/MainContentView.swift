//
//  MainContentView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 9/29/21.
//

import SwiftUI

struct MainContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Tools")) {
                    NavigationLink(destination: MakeQRView()) {
                        Label {
                            Text("Make a QR Code")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "qrcode")
                        }
                    }
                }
                Section(header: Text("Guides")) {
                    NavigationLink(destination: GettingStartedView()) {
                        Label {
                            Text("Enable Extensions")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "puzzlepiece")
                        }
                    }
                    NavigationLink(destination: TipsView()) {
                        Label {
                            Text("Tips")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "lightbulb")
                        }
                    }
                    NavigationLink(destination: PrivacyView()) {
                        Label {
                            Text("Privacy")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "hand.raised")
                        }
                    }
                }
                Section(header: Text("Other")) {
                    NavigationLink(destination: PreferencesView()) {
                        Label {
                            Text("Preferences")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "gear")
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
                    
                }
            }.listStyle(SidebarListStyle())
            VStack() {
                Image(systemName: "qrcode")
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(.accentColor)
                Text("Welcome to QR Pop!\nTurn URLs into QR codes anywhere.")
                    .padding()
                    .multilineTextAlignment(.center)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }.toolbar() {
                Spacer()
            }
        }.navigationTitle("QR Pop")
        .frame(minWidth: 800, minHeight: 400)
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}

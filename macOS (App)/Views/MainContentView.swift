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
                Section(header: Text("Designer")) {
                    NavigationLink(destination: MakeQRView()) {
                    Label {
                        Text("Make a QR code")
                    } icon: {
                        Image(systemName: "qrcode")
                            .foregroundColor(.primary)
                    }
                    }
                }
                Section(header: Text("About")) {
                    NavigationLink(destination: GettingStartedView()) {
                        Label {
                            Text("Getting Started")
                        } icon: {
                            Image(systemName: "flag")
                        }
                    }
                    NavigationLink(destination: TipsView()) {
                    Label {
                        Text("Tips")
                    } icon: {
                        Image(systemName: "lightbulb")
                    }
                    }
                    NavigationLink(destination: PrivacyView()) {
                    Label {
                        Text("Privacy")
                    } icon: {
                        Image(systemName: "hand.raised")
                    }
                    }
                }
                Section(header: Text("Links")) {
                    Link(destination: URL(string: "https://github.com/git-shawn/QR-Pop")!) {
                        Label {
                            Text("Source Code")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "doc.text")
                        }
                    }
                    Link(destination: URL(string: "https://apps.apple.com/us/app/qr-pop/id1587360435")!) {
                        Label {
                            Text("Download for iOS")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "iphone")
                        }
                    }
                    Link(destination: URL(string: "https://qr-pop.glitch.me")!) {
                        Label {
                            Text("Website")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "safari")
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
            }
        }.navigationTitle("QR Pop")
        .frame(minWidth: 600, idealWidth: 750, minHeight: 400, idealHeight: 500)
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}

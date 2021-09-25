//
//  MainContentView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 9/25/21.
//

import SwiftUI

struct MainContentView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: GettingStartedView()) {
                    Label {
                        Text("Getting Started")
                    } icon: {
                        Image(systemName: "flag")
                            .foregroundColor(.red)
                    }
                }
                NavigationLink(destination: TipsView()) {
                    Label {
                        Text("Tips")
                    } icon: {
                        Image(systemName: "lightbulb")
                            .foregroundColor(.orange)
                    }
                }
                NavigationLink(destination: PrivacyView()) {
                    Label {
                        Text("Privacy")
                    } icon: {
                        Image(systemName: "hand.raised")
                            .foregroundColor(.blue)
                    }
                }
                Link(destination: URL(string: "https://github.com/git-shawn/QR-Pop")!) {
                    Label {
                        Text("Source Code")
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    } icon: {
                        Image(systemName: "chevron.left.slash.chevron.right")
                            .foregroundColor(.green)
                    }
                }
                Link(destination: URL(string: "https://qr-pop.glitch.me")!) {
                    Label {
                        Text("Website")
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    } icon: {
                        Image(systemName: "safari")
                            .foregroundColor(.purple)
                    }
                }
            }
            .navigationTitle("QR Pop")
        }.navigationViewStyle(.stack)
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}

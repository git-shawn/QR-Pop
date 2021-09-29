//
//  MainContentView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 9/25/21.
//

import SwiftUI

struct MainContentView: View {
    @State var showQRsheet: Bool = false
    var body: some View {
        NavigationView {
            List {
                Section() {
                    HStack() {
                        Button(action: {
                            showQRsheet = true
                        }, label: {
                            Label {
                                Text("Make a QR Code")
                                    .foregroundColor(.primary)
                            } icon: {
                                Image(systemName: "qrcode")
                                    .foregroundColor(.primary)
                            }
                        })
                        Spacer();
                        Image(systemName: "chevron.right")
                            .font(Font.system(size: 13, weight: .bold, design: .default))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                    }
                }
                Section(){
                NavigationLink(destination: GettingStartedView()) {
                    Label {
                        Text("Getting Started in Safari")
                    } icon: {
                        Image(systemName: "flag.2.crossed")
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
                }
                Section(){
                HStack() {
                    Link(destination: URL(string: "https://github.com/git-shawn/QR-Pop")!) {
                        Label {
                            Text("Source Code")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "chevron.left.slash.chevron.right")
                                .foregroundColor(.green)
                        }
                    }
                    Spacer();
                    Image(systemName: "chevron.right")
                        .font(Font.system(size: 13, weight: .bold, design: .default))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
                HStack() {
                    Link(destination: URL(string: "https://qr-pop.glitch.me")!) {
                        Label {
                            Text("Website")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "safari")
                                .foregroundColor(.purple)
                        }
                    }
                    Spacer();
                    Image(systemName: "chevron.right")
                        .font(Font.system(size: 13, weight: .bold, design: .default))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
                }
            }.navigationTitle("QR Pop")
                .sheet(isPresented: $showQRsheet) {
                  MakeQRView()
            }
        }.navigationViewStyle(.stack)
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
            .preferredColorScheme(.light)
            .previewInterfaceOrientation(.portrait)
    }
}

//
//  MainContentView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 9/25/21.
//

import SwiftUI

struct MainContentView: View {
    var body: some View {
        NavigationView {
            List() {
                //Tools
                Section(){
                    NavigationLink(destination: MakeQRView()){
                        Label {
                            Text("Make a QR Code")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "qrcode")
                                .foregroundColor(.primary)
                        }
                    }
                }
                //Informataion
                Section(){
                    NavigationLink(destination: GettingStartedView()) {
                        Label {
                            Text("Enable Safari Extension")
                        } icon: {
                            Image(systemName: "safari")
                                .foregroundColor(.red)
                        }
                    }
                    NavigationLink(destination: ShareExtensionView()) {
                        Label {
                            Text("Enable Share Sheet Action")
                        } icon: {
                            Image(systemName: "square.and.arrow.up.on.square")
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
                //Outbound links
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
                        //Mimic the right chevron that appaers from NavigationLink
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
                        //Mimic the right chevron that appaers from NavigationLink
                        Image(systemName: "chevron.right")
                            .font(Font.system(size: 13, weight: .bold, design: .default))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                    }
                }
            }.navigationTitle("QR Pop")
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

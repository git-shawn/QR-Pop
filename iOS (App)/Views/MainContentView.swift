//
//  MainContentView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 9/25/21.
//

import SwiftUI

struct MainContentView: View {
    @State private var selectedRow: String?
    
    var body: some View {
        NavigationView {
            List() {
                //Tools
                Section("Tools"){
                    NavigationLink(destination: MakeQRView(), tag: "makeQR", selection: self.$selectedRow){
                        Label {
                            Text("Make a QR Code")
                        } icon: {
                            Image(systemName: "qrcode")
                                .foregroundColor((self.selectedRow == "makeQR" && UIDevice.current.userInterfaceIdiom == .pad) ? .white : .primary)
                        }
                    }
                }
                //Informataion
                Section("Guides"){
                    NavigationLink(destination: GettingStartedView(), tag: "enableSafari", selection: self.$selectedRow) {
                        Label {
                            Text("Enable Safari Extension")
                        } icon: {
                            Image(systemName: "safari")
                                .foregroundColor((self.selectedRow == "enableSafari" && UIDevice.current.userInterfaceIdiom == .pad) ? .white : .red)
                        }
                    }
                    NavigationLink(destination: ShareExtensionView(), tag: "enableShare", selection: self.$selectedRow) {
                        Label {
                            Text("Enable Share Sheet Action")
                        } icon: {
                            Image(systemName: "square.and.arrow.up.on.square")
                                .foregroundColor((self.selectedRow == "enableShare" && UIDevice.current.userInterfaceIdiom == .pad) ? .white : .orange)
                        }
                    }
                    NavigationLink(destination: PrivacyView(), tag: "privacyPolicy", selection: self.$selectedRow) {
                        Label {
                            Text("Privacy")
                        } icon: {
                            Image(systemName: "hand.raised")
                                .foregroundColor((self.selectedRow == "privacyPolicy" && UIDevice.current.userInterfaceIdiom == .pad) ? .white : .blue)
                        }
                    }
                }
                //Outbound links
                Section("Links"){
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
                        Spacer()
                        //Mimic the right chevron that appaers from NavigationLink if iPhone
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            Image(systemName: "chevron.right")
                                .font(Font.system(size: 13, weight: .bold, design: .default))
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                        }
                    }
                    HStack() {
                        Link(destination: URL(string: "mailto:shawnios@outlook.com")!) {
                            Label {
                                Text("Contact")
                                    .foregroundColor(.primary)
                            } icon: {
                                Image(systemName: "envelope")
                                    .foregroundColor(.yellow)
                            }
                        }
                        Spacer()
                        //Mimic the right chevron that appaers from NavigationLink if iPhone
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            Image(systemName: "chevron.right")
                                .font(Font.system(size: 13, weight: .bold, design: .default))
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                        }
                    }
                    HStack() {
                        Link(destination: URL(string: "https://fromshawn.dev/qrpop.html")!) {
                            Label {
                                Text("Website")
                                    .foregroundColor(.primary)
                            } icon: {
                                Image(systemName: "safari")
                                    .foregroundColor(.purple)
                            }
                        }
                        Spacer()
                        //Mimic the right chevron that appaers from NavigationLink if iPhone
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            Image(systemName: "chevron.right")
                                .font(Font.system(size: 13, weight: .bold, design: .default))
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                        }
                    }
                }
            }.navigationTitle("QR Pop")
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

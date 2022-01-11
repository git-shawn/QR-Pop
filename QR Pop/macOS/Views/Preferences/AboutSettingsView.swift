//
//  AboutSettingsView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/24/21.
//
import SwiftUI
import Preferences

struct AboutSettingsView: View {
    @Environment(\.openURL) var openURL
    @State private var showDownload = false
    
    var body: some View {
        Preferences.Container(contentWidth: 300) {
            Preferences.Section(bottomDivider: true, verticalAlignment: .center, label: {
                Image("altAppIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .foregroundColor(.accentColor)
                    .padding(.trailing, 10)
            }, content: {
                VStack(alignment: .leading, spacing: 10) {
                    Text("QR Pop!")
                        .font(.largeTitle)
                        .bold()
                    Text("© 2022 Shawn Davis")
                }
            })
            Preferences.Section(title: "Leave a Review", verticalAlignment: .top) {
                Preferences.Section(title: "", verticalAlignment: .center) {
                    Button(action: {
                        StoreManager.shared.requestReview()
                    }){
                        Text("Review")
                    }
                }
            }
            Preferences.Section(title: "Buy Me a Coffee", bottomDivider: true) {
                Preferences.Section(title: "", verticalAlignment: .center) {
                    Button(action: {
                        StoreManager.shared.leaveTip()
                    }) {
                        Text("Tip $0.99")
                    }
                }
            }
            Preferences.Section(title: "Source Code", verticalAlignment: .top) {
                Preferences.Section(title: "", verticalAlignment: .center) {
                    Button(action: {
                        openURL(URL(string: "https://github.com/git-shawn/QR-Pop")!)
                    }){
                        Text("View")
                    }
                }
            }
            Preferences.Section(title: "Developer's Website", verticalAlignment: .top) {
                Preferences.Section(title: "", verticalAlignment: .center) {
                    Button(action: {
                        openURL(URL(string: "https://fromshawn.dev/qrpop.html")!)
                    }){
                        Text("View")
                    }
                }
            }
            Preferences.Section(title: "Download for iOS", verticalAlignment: .top) {
                Preferences.Section(title: "", verticalAlignment: .center) {
                    Button(action: {
                        showDownload.toggle()
                    }){
                        Text("Get")
                    }.sheet(isPresented: $showDownload) {
                        DownloadIOSView()
                            .onTapGesture {
                                showDownload.toggle()
                            }
                    }
                }
            }
        }
    }
}

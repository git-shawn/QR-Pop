//
//  GettingStartedView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 9/29/21.
//

import SwiftUI
import SafariServices

struct GettingStartedView: View {
    
    var body: some View {
        let extensionBundleIdentifier = "shwndvs.QR-Pop.Extension"
        
        ScrollView {
        HStack() {
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                Text("Enable the Safari Extension")
                    .font(.headline)
                Label {
                    Text("Open Safari")
                } icon: {
                    Image(systemName: "safari")
                        .foregroundColor(.blue)
                }
                Label {
                    Text("Choose Safari > Preferences from the Menu Bar")
                } icon: {
                    Image(systemName: "gear")
                        .foregroundColor(.gray)
                }
                Label {
                    Text("Click Extensions")
                } icon: {
                    Image(systemName: "cursorarrow.rays")
                        .foregroundColor(.red)
                }
                Label {
                    Text("Select the checkbox next to QR Pop")
                } icon: {
                    Image(systemName: "qrcode")
                        .foregroundColor(.orange)
                }
                Button(action: {
                    SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionBundleIdentifier)
                }) {
                    Text("Open Safari Preferences")
                }
                Divider()
                Text("Why should I allow access to all websites?")
                    .font(.headline)
                Text("QR Pop needs to know a webpage's URL in order to generate QR codes. Without website access, the URL is hidden by Safari. Those codes are generated on your device, and your browsing habits are not shared with anyone (ever). You can see more in our privacy policy, or by browsing the source code.")
            }
        }
        }
        .padding(.horizontal, 20)
        .navigationTitle("Getting Started")
    }
}

struct GettingStartedView_Previews: PreviewProvider {
    static var previews: some View {
        GettingStartedView()
    }
}

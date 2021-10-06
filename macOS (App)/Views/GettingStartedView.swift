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
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                Label("Open Safari", systemImage: "1.circle")
                Label("Chose Safari > Preferences from the Menu Bar", systemImage: "2.circle")
                Label("Click Extensions", systemImage: "3.circle")
                Label("Allow QR Pop", systemImage: "4.circle")
                Button(action: {
                    SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionBundleIdentifier)
                }) {
                    Text("Open Safari Preferences")
                }
                Divider()
                Text("Why does QR Pop \"Read and Alter\" all Webpages?")
                    .font(.headline)
                Text("QR Pop works by extracting the URL from a webpage and converting it into a QR code. Allowing this level of access makes the process convenient and automatic. QR Pop contains no trackers/loggers/etc., so you can keep the extension running confidently. All codes are generated on your device, and QR Pop never communicates with a server.\n\nYou can see all of this in our privacy policy or, for those more technically inclined, you can browse the source code yourself.")
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

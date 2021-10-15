//
//  GettingStartedView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 9/29/21.
//

import SwiftUI
import SafariServices

struct GettingStartedView: View {
    
    @State private var showWhyAllowPopover: Bool = false
    
    var body: some View {
        let extensionBundleIdentifier = "shwndvs.QR-Pop.Extension"
        
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    Text("Enable Safari Extension")
                        .font(.title2)
                    Label("Open Safari", systemImage: "1.circle")
                    Label("Chose Safari > Preferences from the Menu Bar", systemImage: "2.circle")
                    Label("Click Extensions", systemImage: "3.circle")
                    Label("Allow QR Pop", systemImage: "4.circle")
                    HStack {
                    Label("Allow All Websites", systemImage: "5.circle")
                        Button(action: {
                            showWhyAllowPopover = true
                        }) {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.accentColor)
                        }.popover(
                            isPresented: self.$showWhyAllowPopover,
                            arrowEdge: .bottom
                        ) {
                            VStack(alignment: .leading) {
                                Text("Why does QR Pop \"Read and Alter\" all Webpages?\n")
                                    .font(.headline)
                                Text("QR Pop works by extracting the URL from a webpage and converting it into a QR code. Allowing this level of access makes the process convenient and automatic. QR Pop contains no trackers/loggers/etc., so you can keep the extension running confidently. All codes are generated on your device, and QR Pop never communicates with a server.\n\nYou can see all of this in our privacy policy or, for those more technically inclined, you can browse the source code yourself.")
                            }.padding()
                            .frame(width: 300)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    Button(action: {
                        SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionBundleIdentifier)
                    }) {
                        Text("Open Safari Preferences")
                    }
                }
                Divider()
                Group {
                    Text("Enable Share Menu Extension")
                        .font(.title2)
                    Label("Open System Preferences", systemImage: "1.circle")
                    Label("Click Extensions", systemImage: "2.circle")
                    Label("Select \"Added Extensions\"", systemImage: "3.circle")
                    Label("Turn on QR Pop", systemImage: "4.circle")
                }
            }.padding()
        }.navigationTitle("Getting Started")
        .toolbar() {
            Spacer()
        }
    }
}

struct GettingStartedView_Previews: PreviewProvider {
    static var previews: some View {
        GettingStartedView()
    }
}

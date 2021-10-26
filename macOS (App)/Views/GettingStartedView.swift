//
//  GettingStartedView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 9/29/21.
//

import SwiftUI
import SafariServices
import AppKit

struct GettingStartedView: View {
    
    @State private var showWhyAllowPopover: Bool = false
    let safImgs = ["macsafext1", "macsafext2", "macsafext3", "macsafext4"]
    let extImgs = ["shrExt1", "shrExt2", "shrExt3"]
    
    var body: some View {
        let extensionBundleIdentifier = "shwndvs.QR-Pop.Extension"
        
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Enable Safari Extension")
                            .font(.title2)
                        Label("Open Safari Extension Preferences Using the Button Below.", systemImage: "1.circle")
                        Label("Allow QR Pop", systemImage: "2.circle")
                        HStack(alignment: .top) {
                        Label("Select Always Allow on Every Website", systemImage: "3.circle")
                            Button(action: {
                                showWhyAllowPopover = true
                            }) {
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(.accentColor)
                            }.popover(
                                isPresented: $showWhyAllowPopover,
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
                        Label("Start Using on Any Website", systemImage: "4.circle")
                        Spacer()
                        Button(action: {
                            SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionBundleIdentifier)
                        }) {
                            Text("Open Safari Preferences")
                        }
                        Spacer()
                    }.padding(.vertical, 15)
                    Spacer()
                    VStack {
                        Spacer()
                        InlinePhotoView(images: safImgs)
                        Spacer()
                    }
                }
                Divider().padding(.vertical)
                HStack(alignment: .top, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Enable Share Menu Extension")
                            .font(.title2)
                        Label("Open System Preferences", systemImage: "1.circle")
                        Label("Click Extensions", systemImage: "2.circle")
                        Label("Select \"Added Extensions\"", systemImage: "3.circle")
                        Label("Click on \"Share Menu\" under QR Pop", systemImage: "4.circle")
                        Spacer()
                        Button(action: {
                            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference")!)
                        }) {
                            Text("Open System Preferences")
                        }
                        Spacer()
                    }.padding(.vertical, 15)
                    Spacer()
                    VStack {
                        Spacer()
                        InlinePhotoView(images: extImgs)
                        Spacer()
                    }
                }
            }.padding()
            .frame(maxWidth: 800)
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

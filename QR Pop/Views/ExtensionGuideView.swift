//
//  ExtensionGuideView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/29/21.
//

import SwiftUI
#if os(macOS)
import SafariServices
#endif

struct ExtensionGuideView: View {
    var body: some View {
        GeometryReader { geometry in
            if (geometry.size.width < 600) {
                ScrollView {
                    VStack {
                        SafariExtensionContent()
                    }
                    Divider()
                        .padding()
                    VStack {
                        ShareExtensionContent()
                    }
                    .padding(.bottom)
                }
            } else {
                ScrollView {
                    HStack {
                        SafariExtensionContent()
                    }
                    Divider()
                        .padding()
                    HStack {
                        ShareExtensionContent()
                    }.padding(.bottom)
                }
            }
        }.navigationTitle("Extension Guides")
        #if os(macOS)
        .frame(minWidth: 500)
        #endif
    }
}

private struct SafariExtensionContent: View {
    #if os(macOS)
    private var safariExtensionSliderImages = ["safext1", "safext2", "safext3", "safext4"]
    #else
    private var safariExtensionSliderImages = ["safext1", "safext2", "safext3", "safext4", "safext5"]
    #endif
    @State private var showAllowSheet: Bool = false

        
    var body: some View {
        Group {
            ImageSlider(images: safariExtensionSliderImages)
            .frame(maxWidth: 400, maxHeight: 300)
            .padding()
            VStack(alignment: .leading, spacing: 10) {
                Text("Safari Extension")
                    .font(.title2)
                    .bold()
                #if os(iOS)
                Label("Open the Settings App", systemImage: "1.circle")
                Label("Tap Safari", systemImage: "2.circle")
                Label("Tap Extensions", systemImage: "3.circle")
                Label("Tap QR Pop", systemImage: "4.circle")
                Label("Turn QR Pop On", systemImage: "5.circle")
                HStack() {
                    Label("Allow \"All Websites\"", systemImage: "6.circle")
                    Spacer()
                    Button(action: {
                        showAllowSheet.toggle()
                    }) {
                        Label("Why?", systemImage: "questionmark.circle")
                            .labelStyle(.iconOnly)
                    }
                    .sheet(
                        isPresented: $showAllowSheet
                    ) {
                        SEPermissionModal(isPresented: $showAllowSheet)
                    }
                }
                #else
                Label("Press \"Open Safari Preferences\" Below", systemImage: "1.circle")
                Label("Find QR Pop in the Sidebar", systemImage: "2.circle")
                Label("Enable QR Pop", systemImage: "3.circle")
                Label("Select \"Always Allow on Every Website\"", systemImage: "4.circle")
                    .help("QR Pop needs enabled on all websites to provide you with our convenient QR Code button everywhere you visit.")
                Label("Start Making QR Codes", systemImage: "5.circle")
                Button(action: {
                    SFSafariApplication.showPreferencesForExtension(withIdentifier: "shwndvs.QR-Pop.Extension")
                }) {
                    Text("Open Safari Preferences")
                }.buttonStyle(QRPopProminentButton())
                #endif
            }
            #if os(iOS)
            .font(.title3)
            #else
            .toolbar {
                Button(action: {
                    showAllowSheet.toggle()
                }) {
                    Label("Why?", systemImage: "questionmark.circle")
                        .labelStyle(.iconOnly)
                }
                .sheet(
                    isPresented: $showAllowSheet
                ) {
                    SEPermissionModal(isPresented: $showAllowSheet)
                }
            }
            #endif
            .frame(maxWidth: 380)
            .padding(.horizontal)
        }
    }
}

private struct ShareExtensionContent: View {
    private var shareExtensionSliderImages = ["actext1", "actext2", "actext3"]
    
    var body: some View {
        Group {
            ImageSlider(images: shareExtensionSliderImages)
            .frame(maxWidth: 400, maxHeight: 300)
            .padding()
            VStack(alignment: .leading, spacing: 10) {
                Group {
                    Text("Share Sheet Extension")
                        .font(.title2)
                        .bold()
                    Label("Open the Share Sheet", systemImage: "1.circle")
                    Label("Scroll to the Bottom", systemImage: "2.circle")
                    #if os(iOS)
                    Label("Tap \"Edit Actions...\"", systemImage: "3.circle")
                    #else
                    Label("Tap \"More...\"", systemImage: "3.circle")
                    #endif
                    Label("Add \"Generate QR Code\"", systemImage: "4.circle")
                }.font(.title3)
                ShareButton(shareContent: [URL(string: "https://apps.apple.com/us/app/qr-pop/id1587360435")!], buttonTitle: "Show Share Sheet", hideIcon: true)
                #if os(iOS)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: 380)
                .padding(.vertical)
                .font(.title3)
                #else
                .buttonStyle(QRPopProminentButton())
                #endif

            }
            .padding(.horizontal)
        }
    }
}

struct ExtensionGuideView_Previews: PreviewProvider {
    static var previews: some View {
        ExtensionGuideView()
    }
}

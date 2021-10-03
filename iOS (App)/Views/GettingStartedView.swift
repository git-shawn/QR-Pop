//
//  GettingStartedView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 9/25/21.
//

import SwiftUI

struct GettingStartedView: View {
    @State private var showPopover: Bool = false
    
    var body: some View {
        ScrollView {
            HStack() {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                Label {
                    Text("Open the Settings App")
                } icon: {
                    Image(systemName: "gear")
                        .foregroundColor(.gray)
                }
                Label {
                    Text("Tap Safari")
                } icon: {
                    Image(systemName: "safari")
                        .foregroundColor(.blue)
                }
                Label {
                    Text("Tap Extensions")
                } icon: {
                    Image(systemName: "puzzlepiece.extension")
                        .foregroundColor(.red)
                }
                Label {
                    Text("Tap QR Pop")
                } icon: {
                    Image(systemName: "qrcode")
                        .foregroundColor(.orange)
                }
                Label {
                    Text("Turn QR Pop On")
                } icon: {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                }
                HStack() {
                    Label {
                        Text("Allow \"All Websites\"")
                    } icon: {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                    }
                    Button(action: {
                        self.showPopover = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.blue)
                    }.popover(
                        isPresented: self.$showPopover,
                        arrowEdge: .bottom
                    ) { ScrollView{
                        VStack(alignment: .leading, spacing: 20) {
                        Text("Why should I allow all websites?")
                            .font(.system(size: 32, weight: .bold))
                        Text("QR Pop works by extracting the URL from a webpage and converting it into a QR code. Allowing \"All Websites\" makes this process convenient and automatic.\n\nGiving an extension the ability to see every URL you visit can be risky business, so Safari checks to make sure you're serious before sharing that information.\n\nYou can be confident knowing no funny business is going on. QR Pop's privacy policy explicitly states that all codes are created on-device and that this app conotains no loggers, trackers, etc.\n\nHowever, for those more technical, you don't need to take my word for it. Feel free to browse the source code and see for yourself.")
                    }.padding(.horizontal, 20)
                    }.padding(.top, 20)
                    }
                }
                }.padding(.horizontal, 20)
            }
                Spacer()
            }
        }
        .navigationBarTitle(Text("Safari Extension"), displayMode: .large)
    }
}

struct GettingStartedView_Previews: PreviewProvider {
    static var previews: some View {
        GettingStartedView()
    }
}

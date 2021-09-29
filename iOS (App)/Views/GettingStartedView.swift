//
//  GettingStartedView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 9/25/21.
//

import SwiftUI

struct GettingStartedView: View {
    
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
                    Text("Select Safari")
                } icon: {
                    Image(systemName: "safari")
                        .foregroundColor(.blue)
                }
                Label {
                    Text("Select Extensions")
                } icon: {
                    Image(systemName: "puzzlepiece.extension")
                        .foregroundColor(.brown)
                }
                Label {
                    Text("Turn QR Pop On")
                } icon: {
                    Image(systemName: "qrcode")
                        .foregroundColor(.orange)
                }
                Label {
                    Text("Allow All Websites")
                } icon: {
                    Image(systemName: "switch.2")
                        .foregroundColor(.green)
                }
                }
                Divider()
                Text("Why should I allow all websites?")
                    .font(.headline)
                Text("QR Pop needs to know a webpage's URL in order to generate QR codes. Without website access, the URL is hidden by Safari. Those codes are generated on your device, and your browsing habits are not shared with anyone (ever). You can see more in our privacy policy, or by browsing the source code.")
            }
        }
        }
        .padding(.horizontal, 20)
        .navigationBarTitle(Text("Getting Started"), displayMode: .large)
    }
}

struct GettingStartedView_Previews: PreviewProvider {
    static var previews: some View {
        GettingStartedView()
    }
}

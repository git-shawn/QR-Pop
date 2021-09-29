//
//  PrivacyView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 9/29/21.
//

import SwiftUI

struct PrivacyView: View {
    
    var body: some View {
        ScrollView {
        VStack() {
            Group {
            HStack() {
                Image(systemName: "hand.raised")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 90, height: 90)
                  .foregroundColor(.blue)
            }
            HStack(spacing: 20) {
                Text("QR Pop does not contain any trackers, and does not collect any user information. \n\nAdditionally, QR Pop will never add tracking via an update. QR Pop creates all QR codes on-device. That means QR Pop never shares your browsing information with a server. Because of this, QR Pop doesn't use any data connection at all to make QR codes.").multilineTextAlignment(.center)
            }
            }.padding(20)
        }
        }
        .navigationTitle("Privacy")
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
    }
}

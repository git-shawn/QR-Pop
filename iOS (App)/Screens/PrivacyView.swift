//
//  PrivacyView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 9/25/21.
//

import SwiftUI

struct PrivacyView: View {

    var body: some View {
        ScrollView {
            VStack() {
                HStack() {
                    Image(systemName: "hand.raised")
                      .resizable()
                      .accessibilityHidden(true)
                      .scaledToFit()
                      .frame(width: 90, height: 90)
                      .foregroundColor(.blue)
                }.padding(.bottom)
                Text("QR Pop does not contain any trackers or loggers, and does not collect any user information. \n\nAdditionally, QR Pop will never add tracking via an update. QR Pop creates all QR codes on-device. That means QR Pop never shares your browsing information with a person, company, or server.")
            }
        }
        .padding(.horizontal, 20)
        .navigationBarTitle(Text("Privacy Policy"), displayMode: .large)
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
    }
}

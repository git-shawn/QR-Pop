//
//  PrivacyPolicyView.swift
//  QR Pop
//
//  Created by Shawn Davis on 10/29/21.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.accentColor)
                    Spacer()
                }.padding(10)
                Group {
                    Text("QR Pop does not contain any trackers or loggers, and does not collect any user information.\n\nAdditionally, QR Pop will never add tracking via an update. QR Pop creates all QR codes on-device. That means QR Pop never shares your browsing information with a person, company, or server.")
                }.padding(.horizontal)
            }
        }.navigationTitle("Privacy Policy")
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}

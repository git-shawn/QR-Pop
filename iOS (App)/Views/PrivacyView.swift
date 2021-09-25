//
//  PrivacyView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 9/25/21.
//

import SwiftUI

struct PrivacyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack() {
            HStack() {
                Image(systemName: "hand.raised")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 90, height: 90)
                  .foregroundColor(.blue)
            }.padding(.bottom)
            HStack(spacing: 20) {
                Text("QR Pop does not contain any trackers, and does not collect any user information. \n\nAdditionally, QR Pop will never add tracking via an update. QR Pop utilizes qrcodejs library to create all QR codes on-device. That means the app never shares your browsing information with a server. In fact, QR Pop contains no trackers whatsoever.")
            }
            Spacer()
        }.padding(20)
        .navigationBarTitle(Text("Privacy Policy"), displayMode: .large)
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
    }
}

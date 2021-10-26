//
//  AboutSettingsView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/24/21.
//

import SwiftUI
import Preferences

struct AboutSettingsView: View {
    
    var body: some View {
        Preferences.Container(contentWidth: 300) {
            Preferences.Section(bottomDivider: true, verticalAlignment: .center, label: {
                Image("iconSelf")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
            }, content: {
                VStack(alignment: .leading, spacing: 10) {
                    Text("QR Pop!")
                        .font(.largeTitle)
                        .bold()
                    Text("© 2021 Shawn Davis")
                }
            })
            Preferences.Section(title: "Leave a Review:") {
                Preferences.Section(title: "") {
                    Button(action: {
                        StoreManager.shared.requestReview()
                    }){
                        Text("Review")
                    }
                }
            }
            Preferences.Section(title: "Buy Me a Coffee:") {
                Preferences.Section(title: "") {
                    Button(action: {
                        StoreManager.shared.leaveTip()
                    }) {
                        Text("Tip $0.99")
                    }
                }
            }
        }
    }
}

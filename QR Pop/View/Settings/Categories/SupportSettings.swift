//
//  SupportSettings.swift
//  QR Pop
//
//  Created by Shawn Davis on 8/13/23.
//

import SwiftUI

struct SupportSettings: View {
    var body: some View {
        Section("Support") {
            Link(destination: URL(string: "https://www.fromshawn.dev/qrpop/support")!, label: {
                Label("QR Pop Help", systemImage: "lifepreserver")
            })
            
#if os(iOS)
            NavigationLink(destination: {
                WebView(url: URL(string: "https://forms.gle/L7aV8KRTT8EXLT2K6")!)
                    .navigationTitle("Feedback")
                    .navigationBarTitleDisplayMode(.inline)
                    .preferredColorScheme(.light)
            }, label: {
                Label("Submit feedback", systemImage: "megaphone")
            })
#else
            Link(destination: URL(string: "https://forms.gle/L7aV8KRTT8EXLT2K6")!, label: {
                Label("Submit feedback", systemImage: "megaphone")
            })
#endif
            
            Link(destination: URL(string: "https://www.fromshawn.dev/qrpop/privacy-policy")!, label: {
                Label("Privacy policy", systemImage: "hand.raised")
            })
        }
#if os(iOS)
        .buttonStyle(OutboundLinkButtonStyle())
#else
        .labelStyle(OutboundLinkLabelStyle())
#endif
    }
}

struct SupportSettings_Previews: PreviewProvider {
    static var previews: some View {
        SupportSettings()
    }
}

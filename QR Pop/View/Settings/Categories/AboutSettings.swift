//
//  AboutSettings.swift
//  QR Pop
//
//  Created by Shawn Davis on 8/13/23.
//

import SwiftUI

struct AboutSettings: View {
    var body: some View {
        Section("About") {
            Group {
                Link(destination: URL(string: "https://github.com/git-shawn/QR-Pop")!, label: {
                    Label("Source code", systemImage: "chevron.left.forwardslash.chevron.right")
                })
                
                Link(destination: URL(string: "mailto:contact@fromshawn.dev?subject=QRPOP%3A")!, label: {
                    Label("Contact me", systemImage: "envelope")
                })
                
                Link(destination: URL(string: "https://testflight.apple.com/join/pW7vfuS0")!, label: {
                    Label("Join the beta", systemImage: "wrench.and.screwdriver.fill")
                })
                
                Link(destination: URL(string: "https://apps.apple.com/us/app/qr-pop/id1587360435?action=write-review")!, label: {
                    Label("Leave a review", systemImage: "heart")
                })
            }
#if os(iOS)
            .buttonStyle(OutboundLinkButtonStyle())
#else
            .labelStyle(OutboundLinkLabelStyle())
#endif
            
            TipButton()
        }
    }
}

struct AboutSettings_Previews: PreviewProvider {
    static var previews: some View {
        AboutSettings()
    }
}

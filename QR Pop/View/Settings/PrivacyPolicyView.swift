//
//  PrivacyPolicyView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/12/23.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text("""
        Thank you for downloading QR Pop! If you're reading this document, that must mean you take your privacy pretty seriously. Thankfully, I do too. You'll be happy to learn that **QR Pop does not collect any personal information**. Not now, not ever.
        
        While QR Pop does support iCloud synchronization, this information is stored within your personal iCloud account and is **not accessible to me**. Additionally, **anonymous usage data** may be shared with me by Apple if you have already agreed to do so. Learn more by reading [Apple's Privacy Policy](https://www.apple.com/legal/privacy/en-ww/).
        
        Of course, if you choose to contact me via email information you share may be retained to facilitate current and future conversations. My email address, [contact@fromshawn.dev](mailto:contact@fromshawn.dev), is also hosted on iCloud.
        
        You are encouraged to verify all these claims by browsing QR Pop's publicly available [Github Repository](https://github.com/git-shawn/QR-Pop). You may also email me with any further questions. Thank you for downloading!
        """)
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PrivacyPolicyView()
        }
    }
}

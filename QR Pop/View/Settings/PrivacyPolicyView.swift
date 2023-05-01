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
        Let's start with the basics: **I do not collect any information**. Period. No personal information, no private information, no analytic data—nothing.
        
        That being said, if you consented to share app-specific analytic information with developers, Apple may collect anonymized usage data on my behalf. You can learn more about this in Apple's article on ["App Analytics & Privacy."](https://www.apple.com/legal/privacy/data/en/app-analytics/)
        
        Additionally, if you have enabled iCloud on your device data may be shared with Apple to facilitate that service. Given that all QR Pop data is backed up to your personal iCloud container, this exchange of information occurs purely between you and Apple. I cannot see what codes you're making and, frankly, I don't want to.
        
        Finally, if you chose to email me some information may be retained to facilitate that conversation. This data includes your email address as well as the contents of the email itself. My email, [contact@fromshawn.dev](contact@fromshawn.dev), also uses iCloud.
        
        For information regarding your privacy when using iCloud, please refer to [Apple's Privacy Policy](https://www.apple.com/legal/privacy/en-ww/).
        
        For my more technically inclined users, you're encouraged to verify all of these claims by perusing this app's publicly available [GitHub repository](https://github.com/git-shawn/QR-Pop). Of course, feel free to reach out to me with any further questions or comments.
        
        Thank you for using QR Pop!
        """)
            .padding()
            
            Text("Last updated 4/30/2023")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom)
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

//
//  AboutView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/9/21.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                HStack {
                    
                    //App website
                    Link(destination: URL(string: "https://fromshawn.dev/qrpop.html")!, label: {
                        Label("Website", systemImage: "globe.americas")
                    }).tint(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .accessibility(hidden: true)
                        .font(Font.system(size: 13, weight: .bold, design: .default))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                    
                }
                
                HStack {
                    
                    //Contact email
                    Link(destination: URL(string: "mailto:contact@fromshawn.dev")!, label: {
                        Label("Contact", systemImage: "envelope")
                    }).tint(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .accessibility(hidden: true)
                        .font(Font.system(size: 13, weight: .bold, design: .default))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
                
                HStack {
                    
                    //Source code
                    Link(destination: URL(string: "https://github.com/git-shawn/QR-Pop")!, label: {
                        Label("Source Code", systemImage: "chevron.left.forwardslash.chevron.right")
                    }).tint(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .accessibility(hidden: true)
                        .font(Font.system(size: 13, weight: .bold, design: .default))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                    
                }
                
                // Privacy policy
                NavigationLink(destination: PrivacyView()) {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }
            }
            Text("Made in Southern Illinois")
                .font(.footnote)
                .opacity(0.3)
        }.navigationTitle("About")
        .listStyle(.insetGrouped)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

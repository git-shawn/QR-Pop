//
//  QRNavigationView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/21/21.
//

import SwiftUI

import SwiftUI

/// A navigational view allowing the user to pick a type of QR code to generate
struct QRNavigationView: View {
    
    @State var initialView: Bool = true
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: MakeQRView(), isActive: $initialView) {
                    Label("URL", systemImage: "link")
                }
                NavigationLink(destination: MakeQRView()) {
                    Label("Wifi Network", systemImage: "wifi")
                }
                NavigationLink(destination: MakeQRView()) {
                    Label("Contact", systemImage: "person.crop.circle")
                }
            }.listStyle(SidebarListStyle())
        }
    }
}

struct QRNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        QRNavigationView()
    }
}

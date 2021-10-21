//
//  QRNavigationView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/17/21.
//

import SwiftUI

/// A navigational view allowing the user to pick a type of QR code to generate
struct QRNavigationView: View {
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        List {
            NavigationLink(destination: LinkQRView()) {
                Label("URL", systemImage: "link")
            }
            NavigationLink(destination: WifiQRView()) {
                Label("Wifi Network", systemImage: "wifi")
            }
            NavigationLink(destination: ContactQRView()) {
                Label("Contact", systemImage: "person.crop.circle")
            }
        }.navigationTitle("QR Code Builder")
        .listStyle(.insetGrouped)
    }
}

struct QRNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        QRNavigationView()
    }
}

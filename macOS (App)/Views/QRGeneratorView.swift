//
//  QRNavigationView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/21/21.
//

import SwiftUI

import SwiftUI

/// A navigational view allowing the user to pick a type of QR code to generate
struct QRGeneratorView: View {
    
    @State var initialView: Bool = true
    
    var body: some View {
        NavigationView {
            List {
                Group {
                    NavigationLink(destination: LinkQRView(), isActive: $initialView) {
                        Label("URL", systemImage: "link")
                    }
                    NavigationLink(destination: TextQRView()) {
                        Label("Text", systemImage: "textformat.alt")
                    }
                    NavigationLink(destination: WifiQRView()) {
                        Label("Wifi Network", systemImage: "wifi")
                    }
                    NavigationLink(destination: ContactQRView()) {
                        Label("Contact", systemImage: "person.crop.circle")
                    }
                }.padding(10)
            }.listStyle(SidebarListStyle())
        }
    }
}

struct QRGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        QRGeneratorView()
    }
}

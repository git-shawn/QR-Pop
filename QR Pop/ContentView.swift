//
//  ViewController.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        #if os(iOS)
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            TabNavigationView()
        } else {
            NavigationView {
                Sidebar()
                QRView()
            }
        }
        #else
        NavigationView {
            Sidebar()
            ScrollView {
                HStack {
                    Spacer()
                    QRLinkView()
                        .frame(maxWidth: 400)
                    Spacer()
                }
                .frame(minWidth: 200)
            }
        }
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



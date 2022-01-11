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
        }
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



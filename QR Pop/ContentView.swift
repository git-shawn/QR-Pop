//
//  ViewController.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var navController: NavigationController
    
    var body: some View {
        #if os(iOS)
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            TabNavigationView()
        } else {
            NavigationView {
                Sidebar()
                QRView()
            }
            .onContinueUserActivity("shwndvs.QR-Pop.generator-selection", perform: { activity in
                if let genId = activity.userInfo?["genId"] as? NSNumber {
                    navController.open(generator: Int(truncating: genId))
                }
            })
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



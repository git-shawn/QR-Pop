//
//  MainContentView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 9/25/21.
//

import SwiftUI

// This extension forces a permanent sidebar on iPad in Portrait and Landscape.
extension UISplitViewController {
    override open func viewDidLoad(){
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            self.preferredSplitBehavior = .tile
            self.preferredDisplayMode = .oneBesideSecondary
            self.displayModeButtonVisibility = .never
        }
    }
}

struct MainContentView: View {
    @State private var selectedRow: String?
    @State private var showSettingsSheet: Bool = false
    
    var body: some View {
        NavigationView {
            Sidebar()
            iPadWelcomeView()
        }
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}

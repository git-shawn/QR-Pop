//
//  MainContentView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 9/25/21.
//

import SwiftUI

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
            QRNavigationView()
        }
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}

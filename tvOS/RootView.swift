//
//  RootView.swift
//  QR Pop TV
//
//  Created by Shawn Davis on 5/25/23.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            TabView {
                ArchiveView()
                    .tabItem {
                        Label("Archive", systemImage: "archivebox")
                    }
                
                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
            }
            .navigationDestination(for: QRModel.self, destination: { model in
                DetailView(model: model)
            })
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}

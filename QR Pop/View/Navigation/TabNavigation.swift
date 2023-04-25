//
//  TabNavigation.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/10/23.
//

import SwiftUI

struct TabNavigation: View {
    @EnvironmentObject var model: NavigationModel
    
    var body: some View {
        TabView(selection: $model.parent.withDefault(.builder(code: nil)), content: {
            ForEach(NavigationModel.Destination.allCases,
                    id: \.rawValue,
                    content: { tab in
                
                NavigationStack(path: $model.path, root: {
                    tab.view
                        .navigationDestination(
                            for: NavigationModel.Destination.self,
                            destination: {
                                $0.view
                            })
                })
                .tabItem {
                    Label(title: {
                        Text(tab.rawValue.capitalized)
                    }, icon: {
                        tab.symbol
                    })
                }
                .tag(tab)
            })
        })
    }
}

struct TabNavigation_Previews: PreviewProvider {
    static var previews: some View {
        TabNavigation()
            .environmentObject(NavigationModel())
    }
}

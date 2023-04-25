//
//  SidebarNavigation.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/10/23.
//

import SwiftUI

struct SidebarNavigation: View {
    @EnvironmentObject var model: NavigationModel
    
    var body: some View {
        NavigationSplitView(sidebar: {
            
            List(selection: $model.parent, content: {
#if os(macOS)
                Text("QR Pop")
                    .font(.largeTitle)
                    .bold()
#endif
                ForEach(NavigationModel.Destination.allCases,
                        id: \.rawValue,
                        content: { listItem in
                    
                    Label(title: {
                        Text(listItem.rawValue.capitalized)
                    }, icon: {
                        listItem.symbol
                    })
                    .tag(listItem)
                })
            })
            .navigationTitle("QR Pop")
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 200, ideal: 225, max: 250)
#endif
            
        }, detail: {
            NavigationStack(path: $model.path, root: {
                model.parent?.view
                    .navigationDestination(for: NavigationModel.Destination.self, destination: {
                        $0.view
                    })
            })
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 575, ideal: 600)
#endif
        })
    }
}

struct SidebarNavigation_Previews: PreviewProvider {
    static var previews: some View {
        SidebarNavigation()
            .environmentObject(NavigationModel())
    }
}

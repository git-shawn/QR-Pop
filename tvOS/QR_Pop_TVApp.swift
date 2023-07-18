//
//  QR_Pop_TVApp.swift
//  QR Pop TV
//
//  Created by Shawn Davis on 5/25/23.
//

import SwiftUI

@main
struct QR_Pop_TVApp: App {
    let persistence = Persistence.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
#if targetEnvironment(simulator)
                .task {
                    persistence.loadPersistenceWithSimualtedData()
                }
#endif
        }
    }
}

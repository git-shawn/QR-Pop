//
//  QR_Pop_WatchOSApp.swift
//  QR Pop WatchOS Watch App
//
//  Created by Shawn Davis on 4/22/23.
//

import SwiftUI

@main
struct QRPopWatchApp: App {
    let persistence = Persistence.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .defaultAppStorage(.appGroup)
#if targetEnvironment(simulator)
                .task {
                    persistence.loadPersistenceWithSimualtedData()
                }
#endif
        }
    }
}

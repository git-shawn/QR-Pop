//
//  QR_PopApp.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/10/23.
//

import SwiftUI

@main
struct QR_PopApp: App {
    let persistence = Persistence.shared
    @AppStorage("isMenuBarActive", store: .appGroup) var isMenuBarActive: Bool = false
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup(id: "main") {
            RootView()
                .handlesExternalEvents(preferring: ["file://", "qrpop://"], allowing: ["*"])
                .environment(\.managedObjectContext, persistence.container.viewContext)
#if os(iOS)
            // MARK: - iOS: Listen for Non-Interactive Scenes
                .onReceive(MirrorModel.shared.sceneWillConnectPublisher, perform: MirrorModel.shared.sceneWillConnect)
                .onReceive(MirrorModel.shared.sceneDidDisconnectPublisher, perform: MirrorModel.shared.sceneDidDisconnect)
#endif
#if targetEnvironment(simulator)
                .task {
                    persistence.loadPersistenceWithSimualtedData()
                }
#endif
        }
        .handlesExternalEvents(matching: ["*"])
        .defaultAppStorage(.appGroup)
#if os(macOS)
        .windowResizability(.contentSize)
#endif
        .commands {
#if os(macOS)
            SettingsCommands()
#endif
            SidebarCommands()
            BuilderCommands()
        }
#if os(macOS)
        
        // MARK: - MacOS QR Code Presentation
        
        WindowGroup("QR Code", id: "codePresentation", for: QRModel.self, content: { model in
            PresentationView(model: model)
        })
        .defaultSize(CGSize(width: 500, height: 500))
        .windowStyle(.hiddenTitleBar)
        
        // MARK: - MacOS Settings
        
        Settings {
            SettingsMenu()
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
        .defaultAppStorage(.appGroup)
        
        // MARK: - Menu Bar Extra
        
        MenuBarExtra("QR Pop",
                     image: "qrpop.icon",
                     isInserted: $isMenuBarActive,
                     content: {
            MenuBarView()
        })
        .defaultAppStorage(UserDefaults.appGroup)
        .menuBarExtraStyle(.window)
        
        WindowGroup("QR Pop", id: "menuBarResults", for: [String].self ) { $results in
            if let results = results {
                MenuBarScanResultsView(results: results)
            }
        }
        .commandsRemoved()
        .defaultSize(width: 300, height: 400)
        .defaultAppStorage(UserDefaults.appGroup)
        .defaultPosition(.center)
#endif
    }
}

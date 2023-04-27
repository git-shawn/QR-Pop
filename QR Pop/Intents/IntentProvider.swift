//
//  IntentProvider.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/26/23.
//

import SwiftUI
import AppIntents

struct QRPopShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .tangerine
    
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ViewArchiveIntent(),
            phrases: ["View my \(.applicationName) Archive"],
            shortTitle: "View QR Code",
            systemImageName: "archivebox")
    }
}

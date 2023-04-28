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
            phrases: [
                "Show me my \(.applicationName) Archive",
                "View my \(.applicationName) Archive",
                "View \(\.$code) in \(.applicationName)",
                "Show me \(\.$code) in \(.applicationName)"
            ],
            shortTitle: "View QR Code",
            systemImageName: "archivebox")
        
        AppShortcut(
            intent: BuildCodeIntent(),
            phrases: [
                "Build a QR Code with \(.applicationName)",
                "Generate a QR Code with \(.applicationName)"
            ],
            shortTitle: "Build QR Code",
            systemImageName: "qrcode")
    }
}

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
    
    /**
     Despite including `"View \(.$code) in \(.applicationName)"` as one of the available phrases,
     it doesn't currently seem possible to actually call invoke Siri with that phrase. However, I'm leaving it in anyway
     in case that feature does become available in later iOS versions.
     */
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ViewArchiveIntent(),
            phrases: [
                "View my \(.applicationName) Archive",
                "Show me my \(.applicationName) Archive",
                "View \(\.$code) in \(.applicationName)"
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

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
                "View my \(.applicationName) Archive",
                "Show me my \(.applicationName) Archive"
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
        
        AppShortcut(
            intent: BuildCodeWithTemplateIntent(),
            phrases: [
                "Build a QR Code with a \(.applicationName) Template",
                "Generate a QR Code with a \(.applicationName) Template"
            ],
            shortTitle: "Build with Template",
            systemImageName: "qrcode")
        
        AppShortcut(
            intent: ScanCodeIntent(),
            phrases: [
                "Scan a QR Code with \(.applicationName)"
            ],
            shortTitle: "Scan QR Code",
            systemImageName: "qrcode.viewfinder")
    }
}

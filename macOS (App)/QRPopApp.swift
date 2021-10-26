//
//  QRPopApp.swift
//  macOS (App)
//
//  Created by Shawn Davis on 9/21/21.
//

import SwiftUI
import Preferences

@main
struct QRPopApp: App {
    @Environment(\.openURL) var openURL
    
    let ExtensionPreferenceViewController: () -> PreferencePane = {
        let paneView = Preferences.Pane(
            identifier: .safExt,
            title: "Safari Extension",
            toolbarIcon: NSImage(systemSymbolName: "safari", accessibilityDescription: "Safari Extension preferences")!
        ) {
            SafariExtensionSettingsView()
        }

        return Preferences.PaneHostingController(pane: paneView)
    }
    
    let AppPreferenceViewController: () -> PreferencePane = {
        let paneView = Preferences.Pane(
            identifier: .mainApp,
            title: "In-App Generator",
            toolbarIcon: NSImage(systemSymbolName: "qrcode", accessibilityDescription: "In-App QR Code Generator Management")!
        ) {
            InAppSettingsView()
        }

        return Preferences.PaneHostingController(pane: paneView)
    }
    
    let AboutViewController: () -> PreferencePane = {
        let paneView = Preferences.Pane(
            identifier: .about,
            title: "About",
            toolbarIcon: NSImage(systemSymbolName: "hand.wave", accessibilityDescription: "About")!
        ) {
            AboutSettingsView()
        }

        return Preferences.PaneHostingController(pane: paneView)
    }
    
    var body: some Scene {
        WindowGroup {
            MainContentView()
        }.commands {
            SidebarCommands()
            CommandGroup(replacing: .appInfo) {
                Button("About QR Pop") {
                    PreferencesWindowController(
                        preferencePanes: [AboutViewController()],
                        style: .toolbarItems,
                        animated: true,
                        hidesToolbarForSingleItem: true
                    ).show()
                }
            }
            CommandGroup(replacing: .help) {
                NavigationLink(destination: TipsView()) {
                    Text("Help")
                }
                NavigationLink(destination: AcknowledgmentsView()) {
                    Text("Acknowledgements")
                }
            }
            CommandGroup(replacing: CommandGroupPlacement.appSettings) {
                Button("Preferences...") {
                    PreferencesWindowController(
                        preferencePanes: [ExtensionPreferenceViewController(), AppPreferenceViewController()],
                        style: .toolbarItems,
                        animated: true,
                        hidesToolbarForSingleItem: true
                    ).show()
                }.keyboardShortcut(KeyEquivalent(","), modifiers: .command)
            }
        }
    }
}

extension Preferences.PaneIdentifier {
    static let safExt = Self("safariExtension")
    static let mainApp = Self("mainApp")
    static let about = Self("about")
}

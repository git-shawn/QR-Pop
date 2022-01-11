//
//  QR Pop.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI
#if os(macOS)
import Preferences
#endif

@main
struct QR_PopApp: App {
    #if os(macOS)
    let appIdentifierPrefix =
        Bundle.main.infoDictionary!["AppIdentifierPrefix"] as! String
    
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
            title: "General",
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
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: {
                    StoreManager.shared.startObserving()
                })
                .onDisappear(perform: {
                    StoreManager.shared.stopObserving()
                })
            #if os(iOS)
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
            #endif
        }
        #if os(macOS)
        .windowToolbarStyle(.unified)
        .handlesExternalEvents(matching: ["*"])
        .commands {
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
                NavigationLink(destination: HelpBook()) {
                    Text("QR Pop Help")
                }
                Link("Contact Me", destination: URL(string: "mailto:contact@fromshawn.dev")!)
                Divider()
                NavigationLink(destination: {
                    PrivacyPolicyView()
                        .frame(width: 450, height: 500)
                }) {
                    Text("Privacy Policy")
                }
                NavigationLink(destination: Acknowledgements()) {
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
        #else
        .defaultAppStorage(UserDefaults(suiteName: "group.shwndvs.qr-pop")!)
        #endif
    }
}

#if os(iOS)
// This extension automatically closes the keyboard when the user taps off of it.
extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// This extension forces a permanent sidebar on iPad in Portrait and Landscape.
extension UISplitViewController {
    override open func viewDidLoad(){
        if (self.traitCollection.horizontalSizeClass == .regular) {
            self.preferredSplitBehavior = .tile
            self.preferredDisplayMode = .oneBesideSecondary
            self.displayModeButtonVisibility = .always
        }
    }
}
#else
extension Preferences.PaneIdentifier {
    static let safExt = Self("safariExtension")
    static let mainApp = Self("mainApp")
    static let about = Self("about")
}
#endif


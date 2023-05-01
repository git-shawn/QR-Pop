//
//  SettingsView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI
import OSLog
#if os(macOS)
import SafariServices
#endif

struct SettingsView: View {
    
    @EnvironmentObject var sceneModel: SceneModel
    @AppStorage("hideInterfaceDuringMirroring", store: .appGroup) private var hideInterfaceDuringMirroring: Bool = true
    @AppStorage("lastMajorVersion", store: .appGroup) var lastMajorVersion: Double = 0.0
    @AppStorage("isMenuBarActive", store: .appGroup) var isMenuBarActive: Bool = false
    @AppStorage("showSiriTips", store: .appGroup) var showSiriTips: Bool = true
    
    @State private var erasingData = false
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Form {
            
            Section(content: {
                if Persistence.shared.cloudAvailable {
                    LabeledContent("Syncing with iCloud", content: {
                        Image(systemName: "checkmark.icloud.fill")
                            .foregroundColor(.cyan)
                    })
                } else {
                    LabeledContent("Not syncing with iCloud", content: {
                        Image(systemName: "xmark.icloud.fill")
                            .foregroundColor(.red)
                    })
                }
            }, header: {
                Text("iCloud")
            }, footer: {
                Text("QR Pop backs up data to your personal iCloud storage container when available. This can be managed in the Settings app.")
#if os(macOS)
                    .font(.footnote)
                    .foregroundColor(.secondary)
#endif
            })
            
#if os(iOS)
            // MARK: - Airplay Mirroring
            
            Section(content: {
                Toggle("Hide Interface When Mirroring", isOn: $hideInterfaceDuringMirroring)
                    .onChange(of: hideInterfaceDuringMirroring) { _ in
                        MirrorModel.shared.disconnectMirroredScene()
                    }
            }, header: {
                Text("Mirroring")
            }, footer: {
                Text("When enabled, QR Pop will project a placeholder image instead of your screen during mirroring sessions.")
            })
            
            Section(content: {
                Toggle("Show Siri Tips", isOn: $showSiriTips)
            }, header: {
                Text("Siri & Shortcuts")
            })
#else
            Section(content: {
                Toggle("Show Scanner in Menu Bar", isOn: $isMenuBarActive)
            }, header: {
                Text("Menu Bar")
            }, footer: {
                Text("Use QR Pop's *Menu Bar Scanner* to read codes on your display. The scanner can also open links and connect to wireless networks.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            })
#endif
            
            // MARK: - "Fine Print" Links
            
            Section("General") {
                Link(destination: URL(string: "https://www.fromshawn.dev/support?qrpop")!, label: {
                    Label("Support", systemImage: "lifepreserver")
                })
#if os(macOS)
                .labelStyle(OutboundLinkLabelStyle())
#else
                .buttonStyle(OutboundLinkButtonStyle())
#endif
                
#if os(iOS)
                NavigationLink(destination: {
                    AppIconView()
                }, label: {
                    Label("Change App Icon", image: "qrpop.icon")
                })
                
                NavigationLink(destination: {
                    PrivacyPolicyView()
                }, label: {
                    Label("Privacy Policy", systemImage: "hand.raised")
                })
                
                ImageButton("Open Privacy Settings", systemImage: "gear", action: {
                    openURL(URL(string: UIApplication.openSettingsURLString)!)
                })
                .buttonStyle(OutboundLinkButtonStyle())
                
                NavigationLink(destination: {
                    AcknowledgementsView()
                }, label: {
                    Label("Acknowledgements", systemImage: "character.book.closed")
                })
#else
                ImageButton("Open Safari Settings", systemImage: "safari", action: {
                    SFSafariApplication.showPreferencesForExtension(withIdentifier: "shwndvs.QR-Pop.SafariExtMac")
                })
                .labelStyle(OutboundLinkLabelStyle())
#endif
            }
            
            // MARK: - Developer Links & Tip
            
            Section("Developer") {
                Link(destination: URL(string: "https://github.com/git-shawn/QR-Pop")!, label: {
                    Label("Source Code", systemImage: "chevron.left.forwardslash.chevron.right")
                })
#if os(macOS)
                .labelStyle(OutboundLinkLabelStyle())
#else
                .buttonStyle(OutboundLinkButtonStyle())
#endif
                
                Link(destination: URL(string: "mailto:contact@fromshawn.dev")!, label: {
                    Label("Contact Me", systemImage: "envelope")
                })
#if os(macOS)
                .labelStyle(OutboundLinkLabelStyle())
#else
                .buttonStyle(OutboundLinkButtonStyle())
#endif
                
                ShareLink("Share QR Pop", item: URL(string: "https://www.fromshawn.dev/qrpop")!)
#if os(macOS)
                    .labelStyle(OutboundLinkLabelStyle())
#else
                    .buttonStyle(OutboundLinkButtonStyle())
#endif
                
                Link(destination: URL(string: "https://apps.apple.com/us/app/qr-pop/id1587360435?action=write-review")!, label: {
                    Label("Leave a Review", systemImage: "star.bubble")
                })
#if os(macOS)
                .labelStyle(OutboundLinkLabelStyle())
#else
                .buttonStyle(OutboundLinkButtonStyle())
#endif
                
                TipButton()
                    .tint(.primary)
            }
            
            // MARK: - Core Data
            
            Section(content: {
                
#if os(macOS)
                LabeledContent("Erase Saved Data", content: {
                    Button("Erase", role: .destructive, action: {
                        erasingData = true
                    })
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                })
#else
                Button("Erase Data", role: .destructive, action: {
                    erasingData = true
                })
#endif
            }, footer: {
                Text("Data will be permanently erased from your device as well as iCloud, if it is enabled. This cannot be undone.")
#if os(macOS)
                    .font(.footnote)
                    .foregroundColor(.secondary)
#endif
            })
            .confirmationDialog(
                "Erase Data",
                isPresented: $erasingData,
                titleVisibility: .automatic,
                actions: {
                    Button("Erase Archive", role: .destructive, action: {
                        do {
                            try Persistence.shared.deleteEntity("QREntity")
                            sceneModel.toaster = .custom(image: Image(systemName: "trash"), imageColor: .accentColor, title: "Erased", note: "Archive erased")
                        } catch {
                            Logger.logView.error("Settings: Could not delete all `QREntities` from the database.")
                            sceneModel.toaster = .error(note: "Archive not erased")
                        }
                    })
                    
                    Button("Erase Templates", role: .destructive, action: {
                        do {
                            try Persistence.shared.deleteEntity("TemplateEntity")
                            sceneModel.toaster = .custom(image: Image(systemName: "trash"), imageColor: .accentColor, title: "Erased", note: "Templates erased")
                        } catch let error {
                            Logger.logView.error("Settings: Could not delete all `TemplateEntities` from the database.")
                            debugPrint(error)
                            sceneModel.toaster = .error(note: "Templates not erased")
                        }
                    })
                    
                    Button("Cancel", role: .cancel, action: {
                        erasingData = false
                    })
                }, message: {
                    Text("Data will be permanently erased from your device as well as iCloud, if it is enabled. This cannot be undone.")
                })
            
            Section(content: {}, footer: {
                Text("**QR Code** is a registered trademark of [DENSO WAVE](https://www.qrcode.com/en/)\nMade with \(Image(systemName:"heart")) in Southern Illinois")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            })
            
            // MARK: - Debug Menu
            
#if DEBUG
            Section("Debug") {
                ImageButton("Success Toast", systemImage: "checkmark.bubble", action: {
                    sceneModel.toaster = .success(note: "You did it!")
                })
                
                ImageButton("Error Toast", systemImage: "exclamationmark.bubble", action: {
                    sceneModel.toaster = .error(note: "That's not good!")
                })
                
                ImageButton("Copied Toast", systemImage: "quote.bubble", action: {
                    sceneModel.toaster = .copied(note: "Well, not really")
                })
                
                ImageButton("Saved Toast", systemImage: "plus.bubble", action: {
                    sceneModel.toaster = .saved(note: "Well, not really")
                })
                
                ImageButton("Custom Toast", systemImage: "star.bubble", action: {
                    sceneModel.toaster = .custom(image: Image(systemName: "party.popper"), imageColor: .pink, title: "Custom!", note: "So fancy...")
                })
            }
            .tint(.primary)
            
            Section {
                
                ImageButton("Deploy CloudKit Schema", systemImage: "icloud.and.arrow.up", action: {
                    do {
                        try Persistence.shared.container.initializeCloudKitSchema()
                    } catch let error {
                        fatalError("\(error)")
                    }
                })
                ImageButton("Reset Version Counter", systemImage: "clock.badge.xmark", action: {
                    lastMajorVersion = 0.0
                    sceneModel.toaster = .success(note: "Whats New Reset")
                })
                
                ImageButton("Wipe Core Data", systemImage: "externaldrive.badge.xmark", action: {
                    do {
                        try Persistence.shared.deleteAllEntities()
                        try Persistence.shared.container.viewContext.atomicSave()
                        sceneModel.toaster = .success(note: "Database erased")
                    } catch {}
                })
            }
            .tint(.primary)
#endif
        }
        .symbolRenderingMode(.hierarchical)
        .navigationTitle("Settings")
#if os(macOS)
        .buttonStyle(.plain)
        .labelStyle(StandardButtonLabelStyle())
        .formStyle(.grouped)
        .frame(minWidth: 400, minHeight: 300)
#endif
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

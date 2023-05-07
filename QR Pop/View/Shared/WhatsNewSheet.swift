//
//  WhatsNewSheet.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/24/23.
//

import SwiftUI

struct WhatsNewSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    let learnMoreURL = URL(string: "https://www.fromshawn.dev/support/qrpop-version-3")!
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack {
                    Group {
                        Text("What's New in ")
                        + Text("QR Pop")
                            .foregroundColor(.accentColor)
                    }
                    .padding(.top)
                    .font(.largeTitle)
                    .bold()
                    
                    Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 30) {
                        GridRow(alignment: .center) {
                            Image(systemName: "paintbrush")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36)
                                .gridColumnAlignment(.center)
                                .foregroundColor(.accentColor)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("A Brand New Designer")
                                    .font(.headline)
                                Text("The reimagined designer brings millions of new style combinations to QR Pop. Create that perfect look, then save it for later as a Template.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        GridRow(alignment: .center) {
                            Image(systemName: "archivebox")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36)
                                .gridColumnAlignment(.center)
                                .foregroundColor(.accentColor)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("A Home for Your Codes")
                                    .font(.headline)
                                Text("Save QR codes you've made to the brand-new Archive for quick access later. Archived codes are available in Spotlight and as Widgets.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        GridRow(alignment: .center) {
                            Image(systemName: "icloud")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36)
                                .gridColumnAlignment(.center)
                                .foregroundColor(.accentColor)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("iCloud Backup")
                                    .font(.headline)
                                Text("View your Archive or use Templates you've created across all your supported devices with iCloud.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        GridRow(alignment: .center) {
                            Image(systemName: "applewatch.side.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36)
                                .gridColumnAlignment(.center)
                                .foregroundColor(.accentColor)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Apple Watch Support")
                                    .font(.headline)
                                Text("Browse the Archive from your wrist with the new Apple Watch app. QR Pop for Apple Watch requires iCloud.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        GridRow(alignment: .center) {
                            Image(systemName: "square.2.layers.3d")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36)
                                .gridColumnAlignment(.center)
                                .foregroundColor(.accentColor)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Siri and Shortcuts")
                                    .font(.headline)
                                Text("Ask Siri to help you view a code in your Archive or build the code entirely using Shortcuts.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        GridRow(alignment: .center) {
                            Image(systemName: "puzzlepiece.extension")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36)
                                .gridColumnAlignment(.center)
                                .foregroundColor(.accentColor)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Better Extensions")
                                    .font(.headline)
                                Text("Create or decode QR codes directly from Share with QR Pop's improved Share Extension.")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .scenePadding()
                    .symbolRenderingMode(.hierarchical)
                    
                    Spacer()
                        .frame(height: 150)
                }
                .scenePadding()
            }
            VStack(spacing: 20) {
                Button("See All New Features", action: {
                    openURL(learnMoreURL)
                })
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
                
                Button("Continue", action: {
#if os(iOS)
                    Haptics.shared.notify(.success)
#endif
                    dismiss()
                })
                .buttonStyle(ProminentFormButtonStyle())
            }
            .scenePadding()
            .frame(maxWidth: .infinity)
            .background(.regularMaterial, ignoresSafeAreaEdges: .all)
        }
    }
}

// MARK: - Whats New View Modifier

struct WhatsNewModifier: ViewModifier {
    @AppStorage("lastMajorVersion", store: .appGroup) var lastMajorVersion: Double = 0.0
    @State private var hasVersionIncremented: Bool = false
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard let version = Bundle.main.releaseVersionNumber,
                      let versionNumber = Double(version),
                      versionNumber > lastMajorVersion
                else { return }
                hasVersionIncremented = true
                lastMajorVersion = versionNumber
            }
            .sheet(isPresented: $hasVersionIncremented, content: {
                WhatsNewSheet()
                #if os(macOS)
                    .frame(minWidth: 400, idealWidth: 500, maxWidth: 600, minHeight: 500, idealHeight: 500, maxHeight: 800)
                #endif
            })
    }
}

extension View {
    
    /// Presents the ``WhatsNewSheet`` if the current `Bundle.releaseVersionNumber`
    /// is higher than the version stored in `UserDefaults`.
    func whatsNewSheet() -> some View {
        modifier(WhatsNewModifier())
    }
}

struct WhatsNewSheet_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewSheet()
    }
}

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
    let learnMoreURL = URL(string: "https://www.fromshawn.dev/qrpop/support/v3-3")!
    
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
                            Image(systemName: "photo.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36)
                                .gridColumnAlignment(.center)
                                .foregroundColor(.accentColor)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Improved Image Overlays")
                                    .font(.headline)
                                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        GridRow(alignment: .center) {
                            Image(systemName: "square.dotted")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36)
                                .gridColumnAlignment(.center)
                                .foregroundColor(.accentColor)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Lorem ipsum dolor ")
                                    .font(.headline)
                                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        GridRow(alignment: .center) {
                            Image(systemName: "square.dotted")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36)
                                .gridColumnAlignment(.center)
                                .foregroundColor(.accentColor)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Lorem ipsum dolor ")
                                    .font(.headline)
                                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        GridRow(alignment: .center) {
                            Image(systemName: "square.dotted")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36)
                                .gridColumnAlignment(.center)
                                .foregroundColor(.accentColor)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Lorem ipsum dolor ")
                                    .font(.headline)
                                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.")
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

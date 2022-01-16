//
//  Sidebar.swift
//  QR Pop
//
//  Created by Shawn Davis on 10/29/21.
//

import SwiftUI

struct Sidebar: View {
    @EnvironmentObject private var navController: NavigationController
    
    #if os(iOS)
    @State private var showSettings: Bool = false
    #endif
    var body: some View {
        List {
            #if os(macOS)
            Section("QR Code Generators") {
                ForEach(QRViews) { view in
                    NavigationLink(destination: QRGeneratorView(generatorType: view), tag: view.id, selection: $navController.activeGenerator) {
                        Label(title: {
                            Text("\(view.name)")
                        }, icon: {
                            if (view.name == "Twitter") {
                                Image("twitterLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(3)
                            } else {
                                Image(systemName: "\(view.icon)")
                            }
                        })
                    }.help(view.description)
                }
            }
            Section("More") {
                NavigationLink(destination: ExtensionGuideView(), tag: Routes.extensions, selection: $navController.activeRoute) {
                    Label("Enable Extensions", systemImage: "puzzlepiece.extension")
                }
                NavigationLink(destination: QRCameraView(), tag: Routes.duplicate, selection: $navController.activeRoute) {
                    Label("Duplicate QR Code", systemImage: "camera.on.rectangle")
                }
            }
            #else
            NavigationLink(destination: QRView(), tag: Routes.generator, selection: $navController.activeRoute) {
                Label("QR Code Generator", systemImage: "qrcode")
            }
            NavigationLink(destination: QRCameraView(), tag: Routes.duplicate, selection: $navController.activeRoute) {
                Label("Duplicate QR Code", systemImage: "camera.on.rectangle")
            }
            NavigationLink(destination: ExtensionGuideView(), tag: Routes.extensions, selection: $navController.activeRoute) {
                Label("Enable Extensions", systemImage: "puzzlepiece.extension")
            }
            #endif
            
        }
        .navigationTitle("QR Pop")
        .listStyle(.sidebar)
        #if os(macOS)
        .frame(minWidth: 200, idealWidth: 250)
        #endif
        .toolbar {
            #if os(macOS)
            ToolbarItem(placement: .cancellationAction) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.leading")
                })
            }
            #else
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button(action: {
                        showSettings.toggle()
                    }) {
                        Label("Settings", systemImage: "gear")
                            .labelStyle(.iconOnly)
                    }
                    Spacer()
                }
            }
            #endif
        }
        #if os(iOS)
        .sheet(isPresented: $showSettings) {
            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showSettings = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(Color(UIColor.secondaryLabel), Color(UIColor.systemFill))
                                    .font(.title2)
                                    .accessibility(label: Text("Close"))
                            }
                        }
                    }
            }
        }
        #endif
    }
}

#if os(macOS)
private func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}
#endif

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar()
    }
}

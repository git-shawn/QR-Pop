//
//  SettingsCommands.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/12/23.
//

#if os(macOS)
import SwiftUI

struct SettingsCommands: Commands {
    
    var body: some Commands {
        Group {
            CommandGroup(replacing: .appInfo, addition: {
                NavigationLink("About QR Pop", destination: {
                    AboutAppView()
                        
                })
                .presentedWindowStyle(.hiddenTitleBar)
                
                Divider()
                
                Link("Source Code", destination: URL(string: "https://github.com/git-shawn/QR-Pop")!)
            })
            
            CommandGroup(replacing: .help, addition: {
                Link("Help", destination: URL(string: "https://www.fromshawn.dev/qrpop/help")!)
                
                Divider()
                
                NavigationLink("Privacy Policy", destination: {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Privacy Policy")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        Divider()
                        PrivacyPolicyView()
                    }
                    .frame(width: 400, height: 450)
                })
                .presentedWindowStyle(.hiddenTitleBar)
                
                NavigationLink("Acknowledgements", destination: {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Acknowledgements")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        Divider()
                        AcknowledgementsView()
                    }
                    .frame(width: 400, height: 450)
                })
                .presentedWindowStyle(.hiddenTitleBar)
            })
        }
    }
}
#endif

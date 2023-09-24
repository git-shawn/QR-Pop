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
                Link("QR Pop help", destination: URL(string: "https://www.fromshawn.dev/qrpop/support")!)
                
                Divider()
                
                Link("Privacy Policy", destination: URL(string: "https://www.fromshawn.dev/qrpop/privacy-policy")!)
                Link("Acknowledgements", destination: URL(string: "https://www.fromshawn.dev/qrpop/support/acknowledgements")!)
                Link("Submit Feedback", destination: URL(string: "https://forms.gle/L7aV8KRTT8EXLT2K6")!)
            })
        }
    }
}
#endif

//
//  PreferencesView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/13/21.
//

import SwiftUI

struct PreferencesView: View {
    
    // Safari Extension QR Code width & height in pixels
    @AppStorage("codeSize", store: UserDefaults(suiteName: (Bundle.main.infoDictionary!["TeamIdentifierPrefix"] as! String))) var codeSize: Int = 190
    
    // Safari Extension hostname visible or not
    @AppStorage("urlToggle", store: UserDefaults(suiteName: (Bundle.main.infoDictionary!["TeamIdentifierPrefix"] as! String))) var urlToggle: Bool = false
    
    // Safari Extension UTM removal on or off
    @AppStorage("referralToggle", store: UserDefaults(suiteName: (Bundle.main.infoDictionary!["TeamIdentifierPrefix"] as! String))) var referralToggle: Bool = false
    
    @State var showTrackingPopover: Bool = false
    
    var body: some View {
        List {
            Section(header: Text("Safari Extension")) {
                // Range from 100 to 300, incrementing by 10
                Stepper(value: $codeSize, in: 100...300, step: 10) {
                    Text("QR Code Size: \(codeSize)px")
                }
                
                // Toggle showing hostname in Safari Extension
                Toggle("Show Webpage URL", isOn: $urlToggle)
                    .toggleStyle(CheckboxToggleStyle())
                
                HStack {
                    Toggle("Remove Tracking Codes", isOn: $referralToggle)
                    .toggleStyle(CheckboxToggleStyle())
                    Button(action: {
                        showTrackingPopover = true
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.accentColor)
                    }.popover(
                        isPresented: self.$showTrackingPopover,
                        arrowEdge: .bottom
                    ) {
                        Text("Links may sometimes include UTM tracking parameters. \nThese can make the link longer, and the QR codes QR Pop generates more complex.").padding()
                            .multilineTextAlignment(.center)
                            .frame(width: 220)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }.navigationTitle("Preferences")
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}

//
//  WifiQRHelpModal.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/17/21.
//

import SwiftUI

/// A modal view to explain wifi terminology
struct WifiQRHelpModal: View {
    @Binding var isPresented: Bool
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("What is an SSID?")
                        .font(.title2)
                        .bold()
                    Text("The SSID is the name of the WiFi Network. Think, for example, \"Public Library Free Wifi.\" Just type it in exactly how it looks")
                    Text("What is WPA and WEP?")
                        .font(.title2)
                        .bold()
                    Text("These are names for the methods your wifi network uses to make connecting nice and secure. You can find out which one you're using in your routers settings or, if you'd like, you can just guess. You've got a 50/50 shot.")
                    Text("Is it safe to enter my WiFi Password?")
                        .font(.title2)
                        .bold()
                    Text("Don't worry! Just like everything else in QR Pop, all processing happens on your device. I couldn't see your WiFi password if I wanted to. If you need more peace of mind, turn off your cellular and WiFi connection. You'll find that everything still works just fine.")
                }.padding()
            }.navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("About Wifi QR Codes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresented = false
                        
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
}

struct WifiQRHelpModal_Previews: PreviewProvider {
    @State static var show: Bool = true
    static var previews: some View {
        WifiQRHelpModal(isPresented: $show)
    }
}

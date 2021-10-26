//
//  TipsView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 9/29/21.
//

import SwiftUI

struct TipsView: View {
    @Environment(\.openURL) var openURL

    var body: some View {
        HStack(spacing: 20){
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Group {
                        Text("What's new?")
                            .font(.headline)
                        Text("You can now create QR codes for Links, Contacts, Text, and Wifi Networks. Just select \"Make a QR Code\" in the app to get started.")
                        Divider()
                    }
                    Group {
                        Text("How do I save a QR code from the Safari Extension?")
                            .font(.headline)
                        Text("Saving or sharing a QR code you've generated in Safari is easy. Just right click on the code like you would any other image. You can drag-and-drop it onto your desktop as well.")
                        Text("I can't scan my QR code.")
                            .font(.headline)
                        Text("There a couple of common issues that could prevent a QR code from scanning. The first is that you may need to move your device closer to scan the code.\nThe second is that you may need to increase the brightness on the device that is presenting the code.")
                        Text("My favorite app shares links, but the share extension isn't appearing.")
                            .font(.headline)
                        Text("That's not good! First things first, make sure that you've enabled the Share Extension. You can find instructions on the \"Enable Extensions\" page. Next, be sure that the app shares links for QR Pop to convert into a code. If you've done all of that, contact me using the button at the bottom of this page so I can try to fix it!")
                        Text("Can I make a QR code for files?")
                            .font(.headline)
                        Text("Yes! (Sort-of)\nQR Pop works with any link, including iCloud file sharing links. If you select iCloud's \"Share File\" button, you'll see \"Generate QR Code\" front and center as one of the options.")
                        }
                    Group {
                        Text("Have a question?")
                            .font(.headline)
                        Text("If you were wondering something that wasn't mentioned here, feel free to contact me using the button below.")
                        Button(action: {openURL(URL(string: "mailto:contact@fromshawn.dev")!)}) {
                            Text("Contact")
                        }
                    }
                }.padding(10)
            }
        }.navigationTitle("Help")
            .frame(width: 450, height: 600)
    }
}

struct TipsView_Previews: PreviewProvider {
    static var previews: some View {
        TipsView()
    }
}

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
            VStack(alignment: .leading, spacing: 20) {
                Group {
                Text("How to save your QR code")
                    .font(.headline)
                Text("Saving or sharing a QR code you've generated in Safari is easy. Just right click on the code like you would any other image. You can drag-and-drop it onto your desktop as well.")
                Text("What to do if your code won't scan")
                    .font(.headline)
                Text("There a couple of common issues that could prevent a QR code from scanning. The first is that you may need to move your device closer to scan the code.\nThe second is that you may need to increase the brightness on the device that is presenting the code.")
                Text("How to use dark mode in QR Pop")
                    .font(.headline)
                Text("Dark mode is automaticly activated alongside your device. That way, QR Pop always matches Safari. Even though the colors on the QR code have been reversed, it'll still scan easily.")
                Text("Have a question?")
                    .font(.headline)
                Text("If you were wondering something that wasn't mentioned here, feel free to contact me using the button below.")
                Button(action: {openURL(URL(string: "mailto:shawnios@outlook.com")!)}) {
                    Text("Contact")
                }
                }
                }.padding(20)
            }
        }.navigationTitle("Tips & Tricks")
    }
}

struct TipsView_Previews: PreviewProvider {
    static var previews: some View {
        TipsView()
    }
}

//
//  TipsView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 9/25/21.
//

import SwiftUI

struct TipsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack(spacing: 20){
            ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("How to save your QR code")
                    .font(.headline)
                Text("Saving or sharing a QR code you've generated is easy. When you long press on the code, a familiar pop-up view will appear with options to save, share, and more! It works just like long pressing any other photo.")
                Text("What to do if your code won't scan")
                    .font(.headline)
                Text("There a couple of common issues that could prevent a QR code from scanning. The first is that you may need to move your device closer to scan the code.\nThe second is that you may need to increase the brightness on the device that is presenting the code.")
                Text("How to use dark mode in QR Pop")
                    .font(.headline)
                Text("Dark mode is automaticly activated alongside your device. That way, QR Pop always matches Safari. Even though the colors on the QR code have been reversed, it'll still scan easily.")
                Text("Have a question?")
                    .font(.headline)
                Text("If you were wondering something that wasn't mentioned here, feel free to contact me using the button below.")
                HStack(){
                    Spacer()
                    Link("Contact", destination: URL(string:"mailto:trusty.09klutzy@icloud.com")!)
                        .font(Font.system(size: 15, weight: .semibold, design: .default))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 10)
                        .background(Color(UIColor.tertiarySystemFill))
                        .cornerRadius(20)
                    Spacer()
                }
            }
        }
        }
        .padding(.horizontal, 20)
        .navigationBarTitle(Text("Tips & Tricks"), displayMode: .large)
    }
}

struct TipsView_Previews: PreviewProvider {
    static var previews: some View {
        TipsView()
    }
}

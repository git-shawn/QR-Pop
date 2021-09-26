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
            VStack(alignment: .leading, spacing: 20) {
                Text("Save or share your QR Code")
                    .font(.headline)
                Text("Saving or sharing a QR code you've generated is easy. When you long press on the code, a familiar pop-up view will appear with options to save, share, and more! It works just like long pressing any other photo.")
                Text("Using dark mode")
                    .font(.headline)
                Text("Dark mode is automaticly activated alongside your device. That way, QR Pop always matches Safari. Even though the colors on the QR code have been reversed, it'll still scan easily.")
                Text("Have a question?")
                    .font(.headline)
                Text("If you were wondering something that wasn't mentioned here, feel free to ask me using the button below.")
                HStack(){
                    Spacer()
                    Link(" Email ", destination: URL(string:"mailto:trusty.09klutzy@icloud.com")!)
                        .padding(10)
                        .background(.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    Spacer()
                }
                Spacer()
            }
        }
        .padding(20)
        .navigationBarTitle(Text("Tips & Tricks"), displayMode: .large)
    }
}

struct TipsView_Previews: PreviewProvider {
    static var previews: some View {
        TipsView()
    }
}

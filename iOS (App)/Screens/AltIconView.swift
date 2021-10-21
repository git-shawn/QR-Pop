//
//  AltIconView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/9/21.
//

import SwiftUI

/// A view to select an alternative icon
struct AltIconView: View {
    // The currently selected icon.
    @State private var activeIconName: String? = UIApplication.shared.alternateIconName
    
    // Allow the user to set an alternate app icon.
    var body: some View {
        List {
            Button(action: {
                UIApplication.shared.setAlternateIconName(nil)
                determineIcon()
            }) {
                HStack {
                    Image("LargeIcon")
                        .cornerRadius(10)
                        .padding(5)
                    
                    VStack(alignment: .leading) {
                        Text("Default")
                        Text("Can't beat the original.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    if (activeIconName == nil) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }.tint(.primary)
            
            Button(action: {
                UIApplication.shared.setAlternateIconName("qralt1")
                determineIcon()
            }) {
                HStack {
                    Image("qralt1")
                        .cornerRadius(10)
                        .padding(5)
                    
                    VStack(alignment: .leading) {
                        Text("Orange!")
                        Text("Louder. Flatter. Orange-er?")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    if (activeIconName == "qralt1") {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }.tint(.primary)
            
            Button(action: {
                UIApplication.shared.setAlternateIconName("qralt2")
                determineIcon()
            }) {
                HStack {
                    Image("qralt2")
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray, lineWidth: 1))
                        .padding(5)
                    
                    VStack(alignment: .leading) {
                        Text("Anti-Orange!")
                        Text("The opposite of Orange! Mysterious.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    if (activeIconName == "qralt2") {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }.tint(.primary)
            
            Button(action: {
                UIApplication.shared.setAlternateIconName("qralt3")
                determineIcon()
            }) {
                HStack {
                    Image("qralt3")
                        .cornerRadius(10)
                        .padding(5)
                    
                    VStack(alignment: .leading) {
                        Text("Black-Out")
                        Text("For a darker, more refined homescreen.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    if (activeIconName == "qralt3") {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }.tint(.primary)
            
            Button(action: {
                UIApplication.shared.setAlternateIconName("qralt4")
                determineIcon()
            }) {
                HStack {
                    Image("qralt4")
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray, lineWidth: 1))
                        .padding(5)
                    
                    VStack(alignment: .leading) {
                        Text("White-Out")
                        Text("Like ink on paper.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    if (activeIconName == "qralt4") {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }.tint(.primary)
            
            Button(action: {
                UIApplication.shared.setAlternateIconName("qralt5")
                determineIcon()
            }) {
                HStack {
                    Image("qralt5")
                        .cornerRadius(10)
                        .padding(5)
                    
                    VStack(alignment: .leading) {
                        Text("Blue")
                        Text("Statistically, your favorite color.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    if (activeIconName == "qralt5") {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }.tint(.primary)
            
            Button(action: {
                UIApplication.shared.setAlternateIconName("qralt6")
                determineIcon()
            }) {
                HStack {
                    Image("qralt6")
                        .cornerRadius(10)
                        .padding(5)
                    
                    VStack(alignment: .leading) {
                        Text("Red")
                        Text("Ka-chow!")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    if (activeIconName == "qralt6") {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }.tint(.primary)
        }.navigationTitle("App Icon")
    }
    
    // Update the state with the current icon.
    func determineIcon() {
        activeIconName = UIApplication.shared.alternateIconName
    }
}

struct AltIconView_Previews: PreviewProvider {
    static var previews: some View {
        AltIconView()
            
    }
}

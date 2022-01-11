//
//  AltIconView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/29/21.
//

import SwiftUI

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
                    Image("iOSIcon")
                        .cornerRadius(10)
                        .padding(5)
                    
                    VStack(alignment: .leading) {
                        Text("Default")
                        Text("Everybody loves the classics.")
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
                    Image("macAlt")
                        .cornerRadius(10)
                        .padding(5)
                    
                    VStack(alignment: .leading) {
                        Text("Mac")
                        Text("An additional dimension just for you.")
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
                    Image("redAlt")
                        .cornerRadius(10)
                        .padding(5)
                    
                    VStack(alignment: .leading) {
                        Text("Red")
                        Group {
                            Text("It won't make your device faster, but it'll *look* faster!")
                        }
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
                    Image("blueAlt")
                        .cornerRadius(10)
                        .padding(5)
                    
                    VStack(alignment: .leading) {
                        Text("Blue")
                        Text("In case you don't already have enough blue app icons.")
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
                UIApplication.shared.setAlternateIconName("qralt7")
                determineIcon()
            }) {
                HStack {
                    Image("greenAlt")
                        .cornerRadius(10)
                        .padding(5)
                    
                    VStack(alignment: .leading) {
                        Text("Green")
                        Text("A little taste of the outdoors.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    if (activeIconName == "qralt7") {
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
                    Image("darkAlt")
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.secondary, lineWidth: 0.5))
                        .padding(5)
                    
                    VStack(alignment: .leading) {
                        Text("Dark Mode")
                        Text("Perfect for thoughtfuly brooding.")
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
                    Image("lightAlt")
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.secondary, lineWidth: 0.5))
                        .padding(5)
                    
                    VStack(alignment: .leading) {
                        Text("Light Mode")
                        Text("Like staring into a flashlight.")
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
                    Image("flatAlt")
                        .cornerRadius(10)
                        .padding(5)
                    
                    VStack(alignment: .leading) {
                        Text("Flat")
                        Text("Same great app, now with none of the gradients.")
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
            
            Button(action: {
                UIApplication.shared.setAlternateIconName("qralt8")
                determineIcon()
            }) {
                HStack {
                    Image("colorAlt")
                        .cornerRadius(10)
                        .padding(5)
                    
                    VStack(alignment: .leading) {
                        Text("Rainbow")
                        Text("Why settle for just one color, anyway?")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    if (activeIconName == "qralt8") {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }.tint(.primary)
        }.navigationTitle("Select an App Icon")
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

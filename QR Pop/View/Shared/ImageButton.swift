//
//  ImageButton.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI

/// A control that initiates an action.
struct ImageButton: View {
    let title: Text
    let image: Image
    let role: ButtonRole?
    let action: () -> ()
    
    /// Creates a button that generates its label from a localized string key and image resource.
    /// - Parameters:
    ///   - title: The key for the button’s localized title, that describes the purpose of the button’s action.
    ///   - image: The name of the image resource to lookup, as well as the localization key with which to label the image.
    ///   - role: An optional semantic role that describes the button. A value of nil means that the button doesn’t have an assigned role.
    ///   - action: The action to perform when the user interacts with the button.
    init(_ title: LocalizedStringKey, image: String, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.title = Text(title)
        self.image = Image(image)
        self.role = role
        self.action = action
    }
    
    /// Creates a button that generates its label from a localized string key and system symbol.
    /// - Parameters:
    ///   - title: The key for the button’s localized title, that describes the purpose of the button’s action.
    ///   - systemImage: The name of the system symbol image. Use the SF Symbols app to look up the names of system symbol images.
    ///   - role: An optional semantic role that describes the button. A value of nil means that the button doesn’t have an assigned role.
    ///   - action: The action to perform when the user interacts with the button.
    init(_ title: LocalizedStringKey, systemImage: String, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.title = Text(title)
        self.image = Image(systemName: systemImage)
        self.role = role
        self.action = action
    }
    
    var body: some View {
        Button(role: role, action: action, label: {
            Label(title: {
                title
            }, icon: {
                image
            })
        })
    }
}

struct ImageButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ImageButton("My Bordered Button", systemImage: "figure.climbing", action: {
                print("Great button!")
            })
            .buttonStyle(.bordered)
            
            ImageButton("My Prominent Button", image: "qrpop.icon", action: {
                print("Excellent button!")
            })
            .buttonStyle(.borderedProminent)
        }
    }
}

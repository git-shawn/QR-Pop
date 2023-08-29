//
//  FormTextFieldStyle.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI

struct FormTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
#if os(macOS)
            .textFieldStyle(.plain)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(LinearGradient.reverseMacAccentStyle, lineWidth: 1)
                    .opacity(0.1)
            )
#endif
            .background(content: {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundColor(Color.secondaryGroupedBackground)
            })
    }
}

struct ContactBuilderTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack {
            configuration
#if os(macOS)
            Divider()
#endif
        }
    }
}

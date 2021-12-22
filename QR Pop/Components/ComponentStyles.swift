//
//  QRPopTextStyle.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/8/21.
//

import SwiftUI

/// A custom text style for QR Pop.
struct QRPopTextStyle: TextFieldStyle {
    #if os(macOS)
    private let gradient = LinearGradient(
        gradient: Gradient(colors: [Color.black, .white]),
        startPoint: .top,
        endPoint: .bottom
    )
    #endif
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .textFieldStyle(.plain)
            .multilineTextAlignment(.leading)
        #if os(iOS)
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 5)
        #else
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .background(.ultraThickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .fill(gradient)
                    .opacity(0.1)
            )
            .padding(10)
        #endif
        #if os(iOS)
        Divider()
            .padding(.leading)
        #endif
    }
}

#if os(macOS)
struct QRPopPlainButton: ButtonStyle {
    
    private let gradient = LinearGradient(
        gradient: Gradient(colors: [Color.white, .black]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .frame(maxWidth: 350)
            .background(.ultraThickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .fill(gradient)
                    .opacity(0.1)
            )
            .padding(10)
            .brightness(configuration.isPressed ? -0.1 : 0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
struct QRPopProminentButton: ButtonStyle {
    private let gradient = LinearGradient(
        gradient: Gradient(colors: [Color.white, .black]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(Color.white)
            .padding(10)
            .frame(maxWidth: 350)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .fill(gradient)
                    .opacity(0.1)
            )
            .padding(10)
            .brightness(configuration.isPressed ? -0.1 : 0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
#endif

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
            .clipShape(Capsule())
            .overlay(
                Capsule()
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

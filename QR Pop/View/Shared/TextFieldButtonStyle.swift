//
//  TextFieldButtonStyle.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI

struct TextFieldButtonStyle: ButtonStyle {
    var placeholder: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            configuration.label
                .foregroundColor(placeholder ? .placeholder : .primary)
            
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
#if os(macOS)
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(.secondary, lineWidth: 1)
                .opacity(0.1)
        )
#endif
        .background(content: {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .foregroundColor(Color.secondaryGroupedBackground)
        })
    }
}

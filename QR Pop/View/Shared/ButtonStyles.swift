//
//  ButtonStylese.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI

// MARK: Form Button Style
/// A ButtonStyle to be applied to Buttons within Builder Forms
struct FormButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.secondaryGroupedBackground)
            .foregroundColor(.accentColor)
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.5 : 1)
#if os(macOS)
            .buttonStyle(.plain)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(LinearGradient.macAccentStyle, lineWidth: 1)
                    .opacity(0.1)
            )
#else
            .hoverEffect(.highlight)
#endif
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct ProminentFormButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .foregroundColor(.secondaryGroupedBackground)
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.5 : 1)
#if os(macOS)
            .buttonStyle(.plain)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(LinearGradient.macAccentStyle, lineWidth: 1)
                    .opacity(0.1)
            )
#else
            .hoverEffect(.highlight)
#endif
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Outbound Link Button Style

/// A ButtonStyle to be applied to outbound links within Forms
struct OutboundLinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .tint(.primary)
            Spacer()
            Image(systemName: "arrow.up.forward")
                .accessibility(hidden: true)
                .font(Font.system(size: 13, weight: .bold, design: .default))
                .foregroundColor(Color.tertiaryLabel)
        }
#if os(macOS)
        .buttonStyle(.plain)
#else
        .hoverEffect(.highlight)
#endif
        .opacity(configuration.isPressed ? 0.5 : 1)
        .contentShape(Rectangle())
    }
}

struct DatePickerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

struct PrimaryLabelButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Button(action: { print("Pressed") }) {
                Label("Form Style", systemImage: "star")
            }
            .buttonStyle(FormButtonStyle())
            
            Button(action: { print("Pressed") }) {
                Label("Prominent Form Style", systemImage: "star")
            }
            .buttonStyle(ProminentFormButtonStyle())
            
            Button(action: { print("Pressed") }) {
                Label("Outbound Links Style", systemImage: "star")
            }
            .buttonStyle(OutboundLinkButtonStyle())
            
        }
        .padding()
        .background(Color.groupedBackground)
    }
}

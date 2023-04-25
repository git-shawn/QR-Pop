//
//  SpringyDisclosureStyle.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/10/23.
//

import SwiftUI

struct SpringyDisclosureStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    configuration.label
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up.circle")
                        .foregroundColor(.accentColor)
                        .imageScale(.large)
                        .transition(.move(edge: .leading))
                        .rotationEffect(.degrees(configuration.isExpanded ? 180 : 0))
                        .animation(.interpolatingSpring(stiffness: 50, damping: 7, initialVelocity: 6), value: configuration.isExpanded)
                }
                .contentShape(Rectangle())
                .padding()
            }
#if os(macOS)
            .buttonStyle(.plain)
#endif
            VStack(alignment: .leading, spacing: 10) {
                if configuration.isExpanded {
                    Divider()
                    configuration.content
                        .padding()
                }
            }
            .transition(.slide)
        }
        .background(Color.secondaryGroupedBackground)
        .cornerRadius(10)
    }
}

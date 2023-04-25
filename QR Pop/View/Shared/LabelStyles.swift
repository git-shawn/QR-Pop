//
//  LabelStyles.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/15/23.
//

import SwiftUI

struct OutboundLinkLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .foregroundColor(.accentColor)
            configuration.title
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "arrow.up.forward")
                .accessibility(hidden: true)
                .font(Font.system(size: 13, weight: .bold, design: .default))
                .foregroundColor(Color.tertiaryLabel)
        }
    }
}

struct StandardButtonLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .foregroundColor(.accentColor)
            configuration.title
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

struct LabelStyles_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Label("I'm a Label", systemImage: "umbrella")
                .labelStyle(OutboundLinkLabelStyle())
        }
        .padding()
        .background(Color.groupedBackground)
        .previewLayout(.fixed(width: 200, height: 300))
    }

}

//
//  iPadWelcomeView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/21/21.
//

import SwiftUI

/// A decorative View for the iPad to show as the Detail View on initial boot.
struct iPadWelcomeView: View {
    var body: some View {
        VStack {
            Image(systemName: "qrcode")
                .font(.system(size: 300, weight: .bold, design: .default))
                .padding(.bottom, 100)
                .foregroundColor(.secondary)
                .opacity(0.1)
                .rotationEffect(.degrees(15))
        }
    }
}

struct iPadWelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        iPadWelcomeView()
    }
}

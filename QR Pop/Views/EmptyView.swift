//
//  EmptyView.swift
//  QR Pop
//
//  Created by Shawn Davis on 10/29/21.
//

import SwiftUI

struct EmptyView: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Image(systemName: "qrcode")
                .font(.system(size: 300, weight: .bold, design: .default))
                .foregroundColor(.gray)
                .opacity(0.1)
                .rotationEffect(.degrees(15))
            Spacer()
        }
    }
}

struct EmptyView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}

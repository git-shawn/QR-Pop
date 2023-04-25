//
//  QRLogoOverlay.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/14/23.
//

import SwiftUI

struct QRLogoOverlay: View {
    @Binding var model: QRModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct QRLogoOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            QRCodeView(qrcode: .constant(QRModel()))
            QRLogoOverlay(model: .constant(QRModel()))
        }
        .padding()
    }
}

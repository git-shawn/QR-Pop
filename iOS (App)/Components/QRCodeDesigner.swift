//
//  QRCodeDesigner.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/18/21.
//

import SwiftUI

/// A panel of design elements to customize a QR code
struct QRCodeDesigner: View {
    @Binding var bgColor: Color
    @Binding var fgColor: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ColorPicker("Background color", selection: $bgColor, supportsOpacity: false)
            ColorPicker("Foreground color", selection: $fgColor, supportsOpacity: false)
        }.padding(.horizontal, 20)
    }
}

struct QRCodeDesigner_Previews: PreviewProvider {
    @State static var bg: Color = .white
    @State static var fg: Color = .black
    static var previews: some View {
        QRCodeDesigner(bgColor: $bg, fgColor: $fg)
    }
}

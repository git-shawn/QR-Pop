//
//  DetailView.swift
//  QR Pop TV
//
//  Created by Shawn Davis on 5/26/23.
//

import SwiftUI

struct DetailView: View {
    let model: QRModel
    
    var body: some View {
        QRCodeView(qrcode: .constant(model))
            .scenePadding()
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(model: QRModel())
    }
}

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
        HStack {
            QRCodeView(qrcode: .constant(model))
                .focusable()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(model.design.backgroundColor.gradient, ignoresSafeAreaEdges: .all)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(model: QRModel())
    }
}

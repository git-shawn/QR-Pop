//
//  QRTextView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRTextView: View {
    @EnvironmentObject var qrCode: QRCode

    @State private var text: String = ""
    @State private var showTextModal: Bool = false

    var body: some View {
        VStack(alignment: .center) {
            TextEditorModal(showTextEditor: $showTextModal, text: $text)
                .onChange(of: showTextModal) {_ in
                    qrCode.setContent(string: text)
                }
        }.onChange(of: qrCode.codeContent, perform: {value in
            if (value.isEmpty) {
                text = ""
            }
        })
    }
}

struct QRTextView_Previews: PreviewProvider {
    static var previews: some View {
        QRTextView()
    }
}

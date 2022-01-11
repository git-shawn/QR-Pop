//
//  QRTextView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRTextView: View {
    @EnvironmentObject var qrCode: QRCode

    @State private var showTextModal: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            TextEditorModal(showTextEditor: $showTextModal, text: $qrCode.formStates[0])
                .onChange(of: showTextModal) {_ in
                    qrCode.setContent(string: qrCode.formStates[0])
                }
        }
    }
}

struct QRTextView_Previews: PreviewProvider {
    static var previews: some View {
        QRTextView()
    }
}

//
//  DownloadIOS.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 11/11/21.
//

import SwiftUI

struct DownloadIOSView: View {
    @State private var qrCode: Data = QRCode().generate(content: "https://apps.apple.com/us/app/qr-pop/id1587360435", fg: .primary, bg: Color("SystemBkg"))
    @State private var fg = Color.primary
    @State private var bg = Color("SystemBkg")
    
    var body: some View {
        VStack {
            QRImage(qrCode: $qrCode, bg: $bg, fg: $fg)
                .padding(.bottom)
            Text("Scan to Download QR Pop for iOS")
                .font(.headline)
        }.padding()
        .frame(width: 300, height: 350)
    }
}

struct DownloadIOSView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadIOSView()
    }
}

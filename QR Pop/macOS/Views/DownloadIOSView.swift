//
//  DownloadIOS.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 11/11/21.
//

import SwiftUI

struct DownloadIOSView: View {
    private let qrCode = QRCode()
    @State private var fg = Color.primary
    @State private var bg = Color("SystemBkg")
    
    init() {
        qrCode.codeContent = "https://apps.apple.com/us/app/qr-pop/id1587360435"
        qrCode.backgroundColor = Color("SystemBkg")
        qrCode.foregroundColor = .primary
    }
    
    var body: some View {
        VStack {
            qrCode.imgData.swiftImage
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

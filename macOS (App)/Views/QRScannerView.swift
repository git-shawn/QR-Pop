//
//  ScanCodeView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/24/21.
//

import SwiftUI
import Combine

struct QRScannerView: View {
    @State var showQRVisionPopover: Bool = false
    @StateObject var visionManager = QRVisionManager()
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                QRVisionViewControllerRepresentable()
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(10)
                VStack(alignment: .leading, spacing: 10){
                    Text("Type of QR Code")
                        .font(.headline)
                    Text("We got back: \(self.visionManager.result)")
                    Text("If actionable, button here.")
                }
            }
        }.navigationTitle("QR Code Scanner")
    }
}

struct QRScannerView_Previews: PreviewProvider {
    static var previews: some View {
        QRScannerView()
    }
}

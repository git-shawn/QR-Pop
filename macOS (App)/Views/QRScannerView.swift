//
//  ScanCodeView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/24/21.
//

import SwiftUI

struct QRScannerView: View {
    var body: some View {
        VStack {
            TabView {
                UploadCodeSubView()
                    .tabItem({
                        Label("Image", systemImage: "photo.on.rectangle")
                    })
                CameraCodeSubView()
                    .tabItem({
                        Label("Camera", systemImage: "camera.aperture")
                    })
            }.padding()
            .navigationTitle("Scan QR Code")
        }
    }
}

struct CameraCodeSubView: View {
    @State var qrCodeScanResult = ""
    
    var body: some View {
        HStack(alignment: .center, spacing: 50) {
            QRVisionViewControllerRepresentable(result : $qrCodeScanResult)
                .frame(width: 300, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct UploadCodeSubView: View {
    var body: some View {
        VStack {
            Text("Upload!")
        }
    }
}

struct QRScannerView_Previews: PreviewProvider {
    static var previews: some View {
        QRScannerView()
    }
}

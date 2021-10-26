//
//  ScanCodeView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/24/21.
//

import SwiftUI

struct ScanCodeView: View {
    var body: some View {
        VStack {
            TabView {
                CameraCodeSubView()
                    .tabItem({
                        Label("Camera", systemImage: "camera.aperture")
                    })
                UploadCodeSubView()
                    .tabItem({
                        Label("Image", systemImage: "photo.on.rectangle")
                    })
            }.padding()
            .navigationTitle("Scan QR Code")
        }
    }
}

struct CameraCodeSubView: View {
    var body: some View {
        VStack {
            Text("Camera")
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

struct ScanCodeView_Previews: PreviewProvider {
    static var previews: some View {
        ScanCodeView()
    }
}

//
//  SaveButton.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 11/11/21.
//

import SwiftUI

struct SaveButton: View {
    let imageSaver = ImageSaver()
    let qrCode: Data
    
    var body: some View {
        Button(action: {
            imageSaver.save(imageData: qrCode)
        }) {
            Label("Save Image", systemImage: "square.and.arrow.down")
        }
    }
}

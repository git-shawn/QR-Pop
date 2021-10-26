//
//  QRImage.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/22/21.
//

import SwiftUI

struct QRImage: View {
    @Binding var qrCode: NSImage
    @State var isSharing: Bool = false
    @Binding var bg: Color
    
    var body: some View {
        Image(nsImage: qrCode)
            .interpolation(.none)
            .resizable()
            .padding(10)
            .frame(width: 320, height: 320)
            .cornerRadius(10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundColor(bg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color(NSColor.underPageBackgroundColor), lineWidth: 2)
            )
            .accessibilityLabel("QR Code Image")
            .onDrag({
                let imgData = qrCode.png
                let provider = NSItemProvider(item: imgData as NSSecureCoding?, typeIdentifier: kUTTypePNG as String)
                provider.previewImageHandler = { (handler, _, _) -> Void in
                    handler?(imgData as NSSecureCoding?, nil)
                }
                return provider
            })
            .contextMenu(menuItems: {
                Button(action: {
                    Clipboard.writeImage(image: qrCode)
                }) {
                    Text("Copy Image")
                }
                Button(action: {
                    ImageSaver().save(image: qrCode)
                }) {
                    Text("Save Image")
                }
                Button(action: {
                    isSharing = true
                }) {
                    Text("Share Image")
                }
            })
            .background(
                SharePicker(isPresented: $isSharing, sharingItems: [qrCode])
            )
    }
}

struct QRImage_Previews: PreviewProvider {
    @State static var image: NSImage = NSImage(imageLiteralResourceName: "codeFailure")
    @State static var bg: Color = .white
    static var previews: some View {
        QRImage(qrCode: $image, bg: $bg)
    }
}

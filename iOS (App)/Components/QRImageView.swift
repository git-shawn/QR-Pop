//
//  QRImageView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/18/21.
//

import SwiftUI
import UniformTypeIdentifiers
import AlertToast

/// Dynamically generates an image of a QR code from a binding input.
/// - Warning: Assure you are passing the correct inputs to the correct types of codes
/// - codeType: The type of QR code to be generated
/// - stringContent: Required for .plain type
/// - eventContent: Required for .event type
/// - contactContent: Required for .contact type
/// - wifiSSIDContent: Required for .wifi type
/// - wifiAuthContent: Required for .wifi type
/// - wifiPassContent: Required for .wifi type
struct QRImageView: View {
    
    @Binding var content: Data?
    @Binding var bg: Color
    @State var showSavedAlert: Bool = false
    
    let qrCode = QRCode()
    
    var body: some View {
        Image(uiImage: UIImage(data: content!)!)
            .interpolation(.none)
            .resizable()
            .padding(10)
            .frame(width: 330, height: 330)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .foregroundColor(bg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color(UIColor.systemGray4), lineWidth: 4)
            )
            .accessibilityLabel("QR Code Image")
            .onDrag({
                let qrImage = content!
                return NSItemProvider(item: qrImage as NSSecureCoding, typeIdentifier: UTType.png.identifier)
            })
            .contextMenu {
                Button {
                    showShareSheet(with: [UIImage(data: content!)!])
                } label: {
                    Label("Share code", systemImage: "square.and.arrow.up")
                }
                Button {
                    let imageSaver = ImageSaver()
                    imageSaver.successHandler = {
                        showSavedAlert = true
                    }
                    imageSaver.writeToPhotoAlbum(image: UIImage(data: content!)!)
                } label: {
                    Label("Save code", systemImage: "square.and.arrow.down")
                }
            }
            .toast(isPresenting: $showSavedAlert, duration: 2) {
                AlertToast(displayMode: .hud, type: .complete(.accentColor), title: "Saved")
            }
    }
}

struct QRImageView_Previews: PreviewProvider {
    @State static var content: Data? = QRCode().generate(content: "", bg: .black, fg: .white)
    @State static var bgColor: Color = .black
    @State static var showShare = false
    static var previews: some View {
        QRImageView(content: $content, bg: $bgColor)
    }
}

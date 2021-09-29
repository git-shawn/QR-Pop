//
//  MakeQRView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 9/26/21.
//

import SwiftUI

struct MakeQRView: View {
    @State private var text = ""
        
    var body: some View {
        VStack() {
            Image(uiImage: UIImage(data: getQRCode(text: text)!)!)
                .resizable()
                .frame(width: 300, height: 300)
                .contextMenu {
                    Button {
                        let imageSaver = ImageSaver()
                        imageSaver.writeToPhotoAlbum(image: UIImage(data: getQRCode(text: text)!)!)
                    } label: {
                        Label("Save code", systemImage: "square.and.arrow.down")
                    }
                }
            TextField("Enter URL", text: $text)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.tertiarySystemFill)))
                .foregroundColor(.black)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
            Button(
                action: {
                    let imageSaver = ImageSaver()
                    imageSaver.writeToPhotoAlbum(image: UIImage(data: getQRCode(text: text)!)!)
                }){
                    Label {
                        Text("Save Code")
                    } icon: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }.buttonStyle(.bordered)
        }.navigationBarTitle(Text("QR Generator"), displayMode: .inline)
    }
    
    func getQRCode(text: String) -> Data? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let data = text.data(using: .ascii, allowLossyConversion: false)
        filter.setValue(data, forKey: "inputMessage")
        guard let ciimage = filter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 25, y: 25)
        let scaledCIImage = ciimage.transformed(by: transform)
        let uiimage = UIImage(ciImage: scaledCIImage)
        return uiimage.pngData()!
    }

    class ImageSaver: NSObject {
        func writeToPhotoAlbum(image: UIImage) {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
        }

        @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            print("Save successful")
        }
    }
}

struct MakeQRView_Previews: PreviewProvider {
    static var previews: some View {
        MakeQRView()
    }
}

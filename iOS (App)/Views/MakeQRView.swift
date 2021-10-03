//
//  MakeQRView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 9/26/21.
//

import SwiftUI
import UniformTypeIdentifiers

struct MakeQRView: View {
    @State private var text = ""
    @State private var bgColor = Color.white
    @State private var fgColor = Color.black
        
    var body: some View {
        ScrollView {
        VStack() {
            Image(uiImage: UIImage(data: getQRCode(text: text, bg: bgColor, fg: fgColor)!)!)
                .interpolation(.none)
                .resizable()
                .frame(width: 330, height: 330)
                .accessibilityLabel("QR Code Image")
                .onDrag({
                    let qrImage = getQRCode(text: text, bg: bgColor, fg: fgColor)!
                    return NSItemProvider(item: qrImage as NSSecureCoding, typeIdentifier: UTType.png.identifier)
                })
                .contextMenu {
                    Button {
                        let imageSaver = ImageSaver()
                        imageSaver.writeToPhotoAlbum(image: UIImage(data: getQRCode(text: text, bg: bgColor, fg: fgColor)!)!)
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
                .submitLabel(.done)
                .disableAutocorrection(true)
                .padding()
            VStack() {
                ColorPicker("Background color", selection: $bgColor, supportsOpacity: false)
                ColorPicker("Foreground color", selection: $fgColor, supportsOpacity: false)
            }.padding(.horizontal, 20)
            Button(
                action: {
                    let imageSaver = ImageSaver()
                    imageSaver.writeToPhotoAlbum(image: UIImage(data: getQRCode(text: text, bg: bgColor, fg: fgColor)!)!)
                }){
                    Label {
                        Text("Save Code")
                    } icon: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }.buttonStyle(.bordered)
                .padding(.top, 20)
        }.padding(.top, 20)
        }.navigationBarTitle(Text("QR Generator"), displayMode: .large)
    }
    
    //Generate the QR Code
    func getQRCode(text: String, bg: Color, fg: Color) -> Data? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        
        let data = text.data(using: .ascii, allowLossyConversion: false)
        filter.setValue(data, forKey: "inputMessage")
        colorFilter.setValue(filter.outputImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(color: UIColor(bg)), forKey: "inputColor1")
        colorFilter.setValue(CIColor(color: UIColor(fg)), forKey: "inputColor0")
        guard let ciimage = colorFilter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 15, y: 15)
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
.previewInterfaceOrientation(.portrait)
    }
}

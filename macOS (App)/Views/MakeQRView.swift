//
//  MakeQRView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 9/29/21.
//

import SwiftUI
import UniformTypeIdentifiers
import Cocoa

struct MakeQRView: View {
    @State private var text = ""
    @State private var bgColor = Color.white //QR code background color
    @State private var fgColor = Color.black //QR code foreground color
        
    var body: some View {
        HStack() {
            Spacer()
            VStack(alignment: .center){
                Image(nsImage: MakeQRView.generateQrImage(from: text, bg: bgColor, fg: fgColor)!)
                    .resizable()
                    .frame(width: 300, height: 300)
//                    .onDrag({
//                        let qrImage = MakeQRView.generateQrImage(from: text, bg: bgColor, fg: fgColor)!
//                        let tiff = qrImage.tiffRepresentation
//                        return NSItemProvider(item: tiff as NSSecureCoding, typeIdentifier: UTType.tiff.identifier)
//                    })
                HStack() {
                TextField("Enter URL", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    Button(action: {
                        showSavePanelThenSave(from: text, bg: bgColor, fg: fgColor)
                    }) {
                        Label {
                            Text("Save")
                        } icon: {
                            Image(systemName: "square.and.arrow.down")
                        }
                    }
                }.frame(width: 300)
                    .padding()
            }
            VStack() {
                ColorPicker("Background color", selection: $bgColor, supportsOpacity: true)
                ColorPicker("Foreground color", selection: $fgColor, supportsOpacity: false)
            }
            Spacer()
        }.navigationTitle("QR Generator")
    }
    
    static func generateQrImage(from string: String, bg: Color, fg: Color) -> NSImage? {
        // create the CIFilter
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }

        // encode the data
        let qrData = string.data(using: String.Encoding.utf8)

        qrFilter.setDefaults()
        qrFilter.setValue(qrData, forKey: "inputMessage")
        qrFilter.setValue("L", forKey: "inputCorrectionLevel")

        // use the filter CIFalseColor to give color to the pixels
        guard let colorFilter = CIFilter(name: "CIFalseColor") else {
            return nil
        }

        // set the color values to the qr color filter
        colorFilter.setDefaults()
        colorFilter.setValue(qrFilter.outputImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(color: NSColor(fg)), forKey: "inputColor0")
        colorFilter.setValue(CIColor(color: NSColor(bg)), forKey: "inputColor1")
        
        let ciImage = colorFilter.outputImage!
        
        let transform = CGAffineTransform(scaleX: 25, y: 25)
        let scaledCIImage = ciImage.transformed(by: transform)
        
        let rep = NSCIImageRep(ciImage: scaledCIImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)

        return nsImage
    }
    
    func showSavePanelThenSave(from codeGen: String, bg: Color, fg: Color) {
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["png"]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = true
        savePanel.allowsOtherFileTypes = false
        savePanel.title = "Save your QR code"
        savePanel.message = "Choose a folder and a name to save your code."
        savePanel.nameFieldLabel = "File name:"
        
        let response = savePanel.runModal()
        if response == NSApplication.ModalResponse.OK {
            let qrNSImage = MakeQRView.generateQrImage(from: codeGen, bg: bg, fg: fg)
            MakeQRView.saveImage(qrNSImage!, atUrl: savePanel.url!)
        }
    }
    
    static func saveImage(_ image: NSImage, atUrl url: URL) {
        guard
            let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
            else { return }
        let newRep = NSBitmapImageRep(cgImage: cgImage)
        newRep.size = image.size
        guard
            let pngData = newRep.representation(using: .png, properties: [:])
            else { return }
        do {
            try pngData.write(to: url)
        }
        catch {
            print("error saving: \(error)")
        }
    }
}

struct MakeQRView_Previews: PreviewProvider {
    static var previews: some View {
        MakeQRView()
    }
}


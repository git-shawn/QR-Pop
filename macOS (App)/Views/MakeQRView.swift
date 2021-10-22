//
//  MakeQRView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 9/29/21.
//

import SwiftUI
import Cocoa

struct MakeQRView: View {
    
    @State private var text = ""
    //QR code background color
    @State private var bgColor = Color.white
    //QR code foreground color
    @State private var fgColor = Color.black
    
    //User preferences to allow autopasting links into the QR Generator or not
    @AppStorage("autoPasteLinks", store: UserDefaults(suiteName: (Bundle.main.infoDictionary!["TeamIdentifierPrefix"] as! String))) var autoPasteLinks: Bool = false
        
    var body: some View {
        VStack() {
            HStack(alignment: .center, spacing: 20){
                Image(nsImage: MakeQRView.generateQrImage(from: text, bg: bgColor, fg: fgColor)!)
                    .resizable()
                    .frame(width: 300, height: 300)
                    .cornerRadius(10)
                    .onDrag({
                        // This works for most apps except Finder?
                        // May be a SwiftUI bug, but worth looking into again later.
                        
                        // Generate the image
                        let qrImage = MakeQRView.generateQrImage(from: text, bg: bgColor, fg: fgColor)!
                        
                        // Convert it to a TIFF, then a PNG
                        let tiffData = qrImage.tiffRepresentation
                        let imageRep = NSBitmapImageRep(data: tiffData!)
                        let imageData = imageRep?.representation(using: .png, properties: [:])
                        
                        // Package it into an NSItemProvider, and return it
                        let provider = NSItemProvider(item: imageData as NSSecureCoding?, typeIdentifier: kUTTypePNG as String)
                        provider.previewImageHandler = { (handler, _, _) -> Void in
                            handler?(imageRep as NSSecureCoding?, nil)
                        }
                        return provider
                    })
                VStack(alignment: .leading) {
                    ColorPicker("Background color", selection: $bgColor, supportsOpacity: true)
                    ColorPicker("Foreground color ", selection: $fgColor, supportsOpacity: false)
                }
            }
            TextField("Enter URL", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
                .frame(maxWidth: 500)
                .padding()
        }.navigationTitle("QR Generator")
        .toolbar {
            Button(action: {
                showSavePanelThenSave(from: text, bg: bgColor, fg: fgColor)
            }) {
                Image(systemName: "square.and.arrow.down")
            }.accessibilityLabel("Save")
            .accessibilityHint("Save QR Code")
            .help("Save QR Code")
            Button(action: {
                print("hello")
            }) {
                Image(systemName: "sidebar.right")
                .accessibilityHint("Customize QR Code's Appearance")
                .help("Customize QR Code Appearance")
            }
        }.onAppear(perform: {
            if autoPasteLinks {
                checkPasteboardForLink()
            }
        })
    }
    
    func checkPasteboardForLink() {
        // Extract the first String from the Pasteboard, if there is one
        let pbItem = NSPasteboard.general.pasteboardItems?.first?.string(forType: .string)
        // Check to see if there was a String
        if (pbItem != nil) {
            // If so, check to see if the String is a URL
            if pbItem!.isValidURL {
                // If so, insert the String into the QR Code generator's text field
                self.text = pbItem!
            }
        }
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

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}

struct MakeQRView_Previews: PreviewProvider {
    static var previews: some View {
        MakeQRView()
    }
}


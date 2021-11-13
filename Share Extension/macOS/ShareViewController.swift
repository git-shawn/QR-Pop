//
//  ShareViewController.swift
//  QR Pop (Share Extension macOS)
//
//  Created by Shawn Davis on 10/14/21.
//

import Cocoa
import CoreServices
import UniformTypeIdentifiers

class ShareViewController: NSViewController {

    @IBOutlet weak var imageView: NSImageCell!
    
    private var processedImage: NSImage?
    private let qrCode = QRCode()
    
    override var nibName: NSNib.Name? {
        return NSNib.Name("ShareViewController")
    }
    
    override func loadView() {
        super.loadView()
    
        let extensionItem = extensionContext?.inputItems[0] as! NSExtensionItem
        let contentTypeURL: String = UTType.url.identifier
        
        //Search the shared objects for a URL
        for attachment in extensionItem.attachments! {
            if attachment.hasItemConformingToTypeIdentifier(contentTypeURL) {
                attachment.loadItem(forTypeIdentifier: contentTypeURL, options: nil, completionHandler: { (responseObject, error) in
                    
                    //Once the URL is found, generate the QR Code
                    if let data = responseObject  as? Data {
                        let dataStr = String(data: data, encoding: .utf8)
                        
                        let urlStringData = dataStr!.data(using: String.Encoding.ascii)
                        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {return}
                        qrFilter.setValue(urlStringData, forKey: "inputMessage")
                        guard let qrImage = qrFilter.outputImage else {return}
                        
                        let transform = CGAffineTransform(scaleX: 10, y: 10)
                        let scaledQrImage = qrImage.transformed(by: transform)
                        
                        let context = CIContext()
                        guard let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) else {return}
                        self.processedImage = NSImage(cgImage: cgImage, size: NSSize(width: 250, height: 250))
                        
                        //Insert the QR Code into the Storyboard
                        DispatchQueue.main.async {
                            self.imageView.image = self.processedImage
                        }
                    } else {
                        let noDataError = NSError(domain: NSCocoaErrorDomain, code: NSFormattingError, userInfo: nil)
                        self.extensionContext!.cancelRequest(withError: noDataError)
                    }
                })
            }
        }
    }

    //Save button
    @IBAction func send(_ sender: AnyObject?) {
        let outputItem = NSExtensionItem()
        
        // Create a save dialog for the user to save their code
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType.png]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = true
        savePanel.allowsOtherFileTypes = false
        savePanel.title = "Save your QR code"
        savePanel.nameFieldStringValue = "QRCode.png"
        savePanel.message = "Choose a folder and a name to save your code."
        savePanel.nameFieldLabel = "File name:"
        
        // Actually save the code to the location selected via the dialog.
        let response = savePanel.runModal()
        if response == NSApplication.ModalResponse.OK {
            self.processedImage!.saveAsPNG(url: savePanel.url!)
            
            // We'll only close the modal if they saved. Otherwise, they'll
            // need to press cancel.
            let outputItems = [outputItem]
            self.extensionContext!.completeRequest(returningItems: outputItems, completionHandler: nil)
        }
}

    //Cancel button
    @IBAction func cancel(_ sender: AnyObject?) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }

}

//An extension to NSImage that saves the object as a PNG
extension NSImage {
    @discardableResult
    func saveAsPNG(url: URL) -> Bool {
        guard let tiffData = self.tiffRepresentation else {
            print("failed to get tiffRepresentation. url: \(url)")
            return false
        }
        let imageRep = NSBitmapImageRep(data: tiffData)
        guard let imageData = imageRep?.representation(using: .png, properties: [:]) else {
            print("failed to get PNG representation. url: \(url)")
            return false
        }
        do {
            try imageData.write(to: url)
            return true
        } catch {
            print("failed to write to disk. url: \(url)")
            return false
        }
    }
}

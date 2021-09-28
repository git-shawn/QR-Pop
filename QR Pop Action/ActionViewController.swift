//
//  ActionViewController.swift
//  QR Pop Action
//
//  Created by Shawn Davis on 9/27/21.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers


class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var badUrlText: UITextView!
    @IBOutlet weak var savePhotoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let content = extensionContext!.inputItems[0] as? NSExtensionItem {
            let contentType = UTType.url.identifier as String
            if (content.attachments) != nil {
                for attachment in content.attachments! {
                    if attachment.hasItemConformingToTypeIdentifier(contentType as String) {
                        attachment.loadItem(forTypeIdentifier: contentType as String, options: nil) { data, error in
                                if error == nil {
                                    var contentString: String? = nil
                                    // Check if the url is URL or String
                                    if let data = data as? String {
                                        contentString = data
                                    } else if let url = data as? URL {
                                        let urlString = url.absoluteString
                                        contentString = urlString
                                    } else { return }
                                    
                                    // Convert String to Data, then to QR Image
                                    let urlStringData = contentString!.data(using: String.Encoding.ascii)
                                    guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {return}
                                    qrFilter.setValue(urlStringData, forKey: "inputMessage")
                                    guard let qrImage = qrFilter.outputImage else {return}
                                    
                                    let transform = CGAffineTransform(scaleX: 10, y: 10)
                                    let scaledQrImage = qrImage.transformed(by: transform)
                                    
                                    let context = CIContext()
                                    guard let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) else {return}
                                    let processedImage = UIImage(cgImage: cgImage)
                                    
                                    DispatchQueue.main.async {
                                    self.imageView.image = processedImage
                                    }
                                }
                        }
                    } else {
                        self.savePhotoButton.isHidden = true;
                        self.badUrlText.isHidden = false;
                    }
                }
            }
        }
    }
    
    @IBAction func savePressed(sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(self.imageView.image!, nil, nil, nil);
    }

    @IBAction func done() {
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}

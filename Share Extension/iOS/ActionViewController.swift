//
//  ActionViewController.swift
//  QR Pop (Share Extension iOS)
//
//  Created by Shawn Davis on 11/2/21.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers


class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var savePhotoButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let content = extensionContext!.inputItems[0] as? NSExtensionItem {
            let contentType = UTType.url.identifier as String
            if (content.attachments) != nil {
                for attachment in content.attachments! {
                    if (attachment.hasItemConformingToTypeIdentifier(contentType as String)) {
                        attachment.loadItem(forTypeIdentifier: contentType as String, options: nil) { data, error in
                                if error == nil {
                                    var contentString: String? = nil
                                    
                                    // Convert url to String
                                    if let url = data as? URL {
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
                                        self.imageView.contentMode = .scaleAspectFit
                                        self.imageView.layer.borderColor = UIColor.black.cgColor
                                        self.imageView.layer.cornerRadius = 16
                                        self.imageView.layer.borderWidth = 3
                                        self.imageView.layer.backgroundColor = UIColor.white.cgColor
                                        self.imageView.image = processedImage.withInset(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
                                    }
                                }
                        }
                    } else if (attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier as String)) {
                        attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier as String, options: nil) { data, error in
                                if error == nil {
                                    var contentString: String? = nil
                                    if let data = data as? String {
                                        // Ensure that the String actually is a URL
                                        // Note, this doesn't guarantee a working URL. https:// would be accepted
                                        if NSURL(string: data) != nil {
                                            contentString = data
                                        }
                                    }
                                    
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
                                        self.imageView.contentMode = .scaleAspectFit
                                        self.imageView.layer.borderColor = UIColor.black.cgColor
                                        self.imageView.layer.cornerRadius = 16
                                        self.imageView.layer.borderWidth = 3
                                        self.imageView.layer.backgroundColor = UIColor.white.cgColor
                                        self.imageView.image = processedImage.withInset(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
                                    }
                                }
                            }
                        } else {
                            self.savePhotoButton.isEnabled = false;
                            self.imageView.image = UIImage(imageLiteralResourceName: "codeFailure")
                    }
                }
            }
        }
    }
    
    @IBAction func savePressed() {
        UIImageWriteToSavedPhotosAlbum(self.imageView.image!, nil, nil, nil);
        let alertController = UIAlertController(title: "Image Saved", message: "The QR code was saved to your photo library.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func done() {
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}

extension UIImage {
    func withInset(_ insets: UIEdgeInsets) -> UIImage? {
        let cgSize = CGSize(width: self.size.width + insets.left * self.scale + insets.right * self.scale,
                            height: self.size.height + insets.top * self.scale + insets.bottom * self.scale)

        UIGraphicsBeginImageContextWithOptions(cgSize, false, self.scale)
        defer { UIGraphicsEndImageContext() }

        let origin = CGPoint(x: insets.left * self.scale, y: insets.top * self.scale)
        self.draw(at: origin)

        return UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(self.renderingMode)
    }
}

//
//  ShareViewController.swift
//  Share Extension Mac
//
//  Created by Shawn Davis on 4/22/23.
//

import Cocoa
import SwiftUI

class ShareViewController: NSViewController {
    
    override func loadView() {
        let sharedItem = self.extensionContext?.inputItems[0] as? NSExtensionItem
        
        let hostingController = NSHostingController(rootView: ShareView(sharedItem: sharedItem, dismiss: completeRequest))
        let hostedView = hostingController.view
        
        hostedView.invalidateIntrinsicContentSize()
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        hostedView.frame = NSRect(origin: .zero, size: CGSize(width: 500, height: 500))
        
        self.view = hostedView
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func completeRequest() {
        self.extensionContext?.completeRequest(returningItems: nil)
    }
    
}

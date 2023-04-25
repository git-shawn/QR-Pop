//
//  ShareViewController.swift
//  Share Extension iOS
//
//  Created by Shawn Davis on 4/22/23.
//

import UIKit
import SwiftUI

class ShareViewController: UIViewController {
    
    override func loadView() {
        super.loadView()
        let sharedItem = self.extensionContext?.inputItems[0] as? NSExtensionItem
        
        let hostingController = UIHostingController(rootView: ShareView(sharedItem: sharedItem, dismiss: completeRequest))
        guard let hostedView = hostingController.view else { return }
        
        hostedView.invalidateIntrinsicContentSize()
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        hostedView.backgroundColor = .systemGroupedBackground
        
        hostingController.navigationController?.navigationBar.tintColor = UIColor.systemGroupedBackground
        hostingController.navigationController?.navigationBar.barTintColor = UIColor(named: "AccentColor")
        
        self.addChild(hostingController)
        self.view.addSubview(hostedView)
        
        hostedView.frame = view.bounds
        
        NSLayoutConstraint.activate([
            hostedView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            hostedView.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostedView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }

    func completeRequest() {
        self.extensionContext?.completeRequest(returningItems: nil)
    }

}

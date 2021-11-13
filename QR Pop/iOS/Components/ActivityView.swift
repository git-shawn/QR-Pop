//
//  ActivityView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 11/1/21.
//

import Foundation
import SwiftUI
import UIKit

extension View {
    /// Display UIActivityViewController (Share Sheet) when called for a parameter passed. This function handles presentation.
    /// - Parameter activityItems: The Activity Item to be shared.
    func showShareSheet(with activityItems: [Any], formatImageToPrint: Bool = false) {
        //TODO: Windows is deprecated in iOS15. Come up with an alternative to this.
        guard let source = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        var activityItemsPrintable: [Any]
        if formatImageToPrint {
            let printInfo = UIPrintInfo(dictionary: nil)
            printInfo.outputType = .general
            printInfo.jobName = "QR Pop Print"
            activityItemsPrintable = (activityItems + [printInfo])
        } else {
            activityItemsPrintable = activityItems
        }
        
        let activityVC = UIActivityViewController(
        activityItems: activityItemsPrintable,
        applicationActivities: nil)
        
        //Present a popover view in the center of the screen for an iPad.
        //TODO: Attatch the popover to it's source in some way.
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = source.view
            popoverController.sourceRect = CGRect(x: source.view.bounds.midX,
                                                y: source.view.bounds.midY,
                                                width: .zero, height: .zero)
            popoverController.permittedArrowDirections = []
        //Present an adaptive modal for iOS. Half the screen initially, then full screen on scroll.
        } else { if let sheet = activityVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            }
        }
        
        //  In iOS 15.1 the ShareSheet may disappear but not close, blocking the app from presenting another one.
        //  This fixes that issue by dismissing any presented controllers there may be first.
        DispatchQueue.main.async {
            source.presentedViewController?.dismiss(animated: false, completion: nil)
            source.present(activityVC, animated: true)
        }
    }
}

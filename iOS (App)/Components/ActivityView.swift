//
//  ActivityView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/20/21.
//

import Foundation
import SwiftUI
import UIKit

extension View {
    /// Display UIActivityViewController (Share Sheet) when called for a parameter passed. This function handles presentation.
    /// - Parameter activityItems: The Activity Item to be shared.
    func showShareSheet(with activityItems: [Any]) {
        //TODO: Windows is deprecated in iOS15. Come up with an alternative to this.
        guard let source = UIApplication.shared.windows.last?.rootViewController else {
            return
        }
        
        let activityVC = UIActivityViewController(
        activityItems: activityItems,
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
        source.present(activityVC, animated: true)
    }
}

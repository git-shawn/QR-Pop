//
//  WidgetActivity.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 1/16/22.
//

import Foundation
import SwiftUI
import UIKit
import WidgetKit

class WidgetActivity: UIActivity {
    
    override var activityTitle: String?{
        return "Set as Widget"
    }
    
    override var activityImage: UIImage?{
        return UIImage(systemName: "rectangle.badge.plus")
    }
 
    override var activityType: UIActivity.ActivityType{
        return UIActivity.ActivityType.widgetActivity
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        if activityItems.contains(where: { obj in
            if obj is UIImage {
                return true
            } else {
                return false
            }
        }) {
        return true
        } else {
        return false
        }
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        let codeImage = activityItems.first! as! UIImage
        UserDefaults(suiteName: "group.shwndvs.qr-pop")?.set(codeImage.pngData()!, forKey: "widgetImg")
        WidgetCenter.shared.reloadAllTimelines()
        print("sent to widget")
    }
}

extension UIActivity.ActivityType {
    static let widgetActivity = UIActivity.ActivityType("shwndvs.QR-Pop.widgetActivity")
}

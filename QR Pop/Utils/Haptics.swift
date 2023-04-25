//
//  Haptics.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

#if canImport(UIKit)
import UIKit

class Haptics {
    static let shared = Haptics()
    
    private init() { }
    
    func fire(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}
#endif

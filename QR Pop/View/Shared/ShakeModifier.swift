//
//  ShakeModifier.swift
//  QR Pop
//
//  Created by Shawn Davis on 08/12/2023
//  Based on an article by Paul Hudson
//  https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-shake-gestures
//

#if os(iOS)
import SwiftUI

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

extension UIWindow {
     open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
     }
}

struct ShakeViewModifier: ViewModifier {
    @AppStorage("detectShakes") private var detectShakes: Bool = true
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                if detectShakes {
                    action()
                }
            }
    }
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(ShakeViewModifier(action: action))
    }
}
#endif

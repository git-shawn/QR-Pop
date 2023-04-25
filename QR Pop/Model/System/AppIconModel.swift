//
//  AppIconModel.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/24/23.
//  Created with this tutorial:
//  https://www.avanderlee.com/swift/alternate-app-icon-configuration-in-xcode/
//

#if os(iOS)
import SwiftUI
import OSLog

class AppIconModel: ObservableObject {
    @Published private(set) var selectedAppIcon: AppIcon
    
    init() {
        if let iconName = UIApplication.shared.alternateIconName, let appIcon = AppIcon(rawValue: iconName) {
            selectedAppIcon = appIcon
        } else {
            selectedAppIcon = .primary
        }
    }
    
    func updateAppIcon(to icon: AppIcon) {
        let previousAppIcon = selectedAppIcon
        selectedAppIcon = icon

        Task { @MainActor in
            guard UIApplication.shared.alternateIconName != icon.value else {
                return
            }

            do {
                try await UIApplication.shared.setAlternateIconName(icon.value)
            } catch {
                Logger(subsystem: Constants.bundleIdentifier, category: "appIconModel")
                    .error("Updating icon to \(icon.rawValue) failed")
                selectedAppIcon = previousAppIcon
            }
        }
    }
}

// MARK: - Icon Styles Enum

extension AppIconModel {
    
    enum AppIcon: String, CaseIterable, Identifiable {
        case primary = "AppIcon"
        case dark = "AppIcon-Dark"
        case blue = "AppIcon-Blue"
        case green = "AppIcon-Green"
        case mac = "AppIcon-Mac"
        case purple = "AppIcon-Purple"
        case red = "AppIcon-Red"
        case white = "AppIcon-White"
        
        var id: String { rawValue }
        
        var value: String? {
            switch self {
            case .primary:
                return nil
            default:
                return rawValue
            }
        }
        
        var description: String {
            switch self {
            case .primary:
                return "Default"
            case .blue:
                return "Blue"
            case .dark:
                return "Dark"
            case .green:
                return "Green"
            case .mac:
                return "MacOS"
            case .purple:
                return "Purple"
            case .red:
                return "Red"
            case .white:
                return "White"
            }
        }
        
        var iconImage: Image {
            Image("Preview-\(rawValue)")
        }
    }
}
#endif

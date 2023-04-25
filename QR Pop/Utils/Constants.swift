//
//  Constants.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import Foundation
import CoreGraphics
import OSLog

struct Constants {
    private init() {}
}

extension Constants {
    
    static let groupIdentifier = "group.shwndvs.qr-pop"
    
    // These values should absolutely not be `nil`.
    static let bundleIdentifier = Bundle.main.bundleIdentifier!
    static let buildVersionNumber = Bundle.main.buildVersionNumber!
    static let releaseVersionNumber = Bundle.main.releaseVersionNumber!
    
    // Handoff Values
    static let builderHandoffActivity = "shwndvs.qr-pop.buildingCode"
    
    static let viewLogger = Logger(
        subsystem: Constants.bundleIdentifier,
        category: "view"
    )
}

// MARK: - Extend Bundle

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

// MARK: - DEBUG Variables

#if DEBUG
extension Constants {
    
    static let loremIpsum = """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Volutpat maecenas volutpat blandit aliquam etiam erat velit scelerisque. Sit amet consectetur adipiscing elit pellentesque habitant morbi. Pellentesque pulvinar pellentesque habitant morbi tristique senectus. Risus sed vulputate odio ut enim. In est ante in nibh mauris cursus. Suspendisse in est ante in nibh mauris cursus mattis molestie. Ac tortor vitae purus faucibus ornare suspendisse sed. Est lorem ipsum dolor sit amet consectetur. Pellentesque habitant morbi tristique senectus et netus. Libero justo laoreet sit amet. Scelerisque in dictum non consectetur a erat nam at. Tellus pellentesque eu tincidunt tortor aliquam nulla facilisi cras fermentum. Vulputate ut pharetra sit amet aliquam id diam maecenas. Convallis posuere morbi leo urna. Id velit ut tortor pretium viverra. Ut tortor pretium viverra suspendisse potenti nullam ac. Nunc scelerisque viverra mauris in aliquam sem fringilla ut morbi. Odio tempor orci dapibus ultrices in. Eu mi bibendum neque egestas.
    """
}
#endif

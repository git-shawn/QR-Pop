//
//  UserDefaults+QRPOp.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/12/23.
//

import Foundation

extension UserDefaults {
    
    /// UserDefaults stored in the standard App Group defined in ``Variables``.
    static var appGroup: UserDefaults {
        UserDefaults(suiteName: Constants.groupIdentifier)!
    }
}

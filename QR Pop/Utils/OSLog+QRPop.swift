//
//  OSLog+QRPop.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/27/23.
//

import OSLog
import SwiftUI

extension Logger {
    
    static let logView = Logger(subsystem: "group.shwndvs.qr-pop", category: "View")
    static let logModel = Logger(subsystem: "group.shwndvs.qr-pop", category: "Model")
    static let logPersistence = Logger(subsystem: "group.shwndvs.qr-pop", category: "Persistence")
    static let logExtension = Logger(subsystem: "group.shwndvs.qr-pop", category: "Extension")
}

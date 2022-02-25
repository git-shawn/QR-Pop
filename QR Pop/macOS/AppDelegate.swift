//
//  AppDelegate.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 2/25/22.
//

import Foundation
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

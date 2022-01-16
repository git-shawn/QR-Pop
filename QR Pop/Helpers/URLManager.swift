//
//  URLManager.swift
//  QR Pop
//
//  Created by Shawn Davis on 1/16/22.
//

import Foundation
import SwiftUI
#if os(macOS)
import Cocoa
#endif

class URLManager: NSObject {
    struct XCallback {
        var source: String?
        var success: String?
        var error: String?
        var cancel: String?
    }
    
    private var xcallback: XCallback? = nil
    
    func handle(url: URL, nav: NavigationController) {
        switch url.host {
        case .some("x-callback-url"):
            print("x-callback-url not yet supported...")
            break
        case .some("generate"):
            handleGenerator(url: url, nav: nav)
        case .some("duplicate"):
            nav.open(route: .duplicate)
        case .some("extension"):
            nav.open(route: .extensions)
        case .some("settings"):
            nav.open(route: .settings)
        case .none:
            break
        default:
            break
        }
    }
    
    private func handleGenerator(url: URL, nav: NavigationController) {
        guard let query = url.query else {return}
        print(query)
        let param = query.split(separator: "=")
        if (param[0] == "id") {
            guard let id = Int(param[1]) else {return}
            if !(id > QRViews.endIndex) {
                nav.open(generator: id)
            }
        }
    }
}

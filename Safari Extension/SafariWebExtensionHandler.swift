//
//  SafariWebExtensionHandler.swift
//  SafariExt
//
//  Created by Shawn Davis on 3/22/23.
//

import SafariServices
import OSLog

#if os(macOS)
let SFExtensionMessageKey = "message"
#endif

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        Logger().error("Recieved a message from the browser. This is unexpected behavior.")
        context.completeRequest(returningItems: nil, completionHandler: nil)
    }

}

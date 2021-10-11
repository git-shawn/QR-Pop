//
//  SafariWebExtensionHandler.swift
//  Shared (Extension)
//
//  Created by Shawn Davis on 9/21/21.
//

import SafariServices
import os.log

let SFExtensionMessageKey = "message"

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {

        let item = context.inputItems[0] as! NSExtensionItem
        let message = item.userInfo?[SFExtensionMessageKey]
        
        let messageDictionary = message as? [String: String]
        if messageDictionary?["message"] == "getDefaults" {
            
            // No preferences on Mac version yet. Default values instead.
            let codeSize = 190
            let showHostname = true
            let makeBrighter = false
            
            let response = NSExtensionItem()
            response.userInfo = [ SFExtensionMessageKey: [ "codeSize": codeSize, "showHostname": showHostname, "makeBrighter": makeBrighter ] ]
            context.completeRequest(returningItems: [response], completionHandler: nil)
        }
    }
}

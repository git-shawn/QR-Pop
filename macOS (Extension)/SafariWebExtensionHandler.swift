//
//  SafariWebExtensionHandler.swift
//  Shared (Extension)
//
//  Created by Shawn Davis on 9/21/21.
//

import SafariServices

let SFExtensionMessageKey = "message"

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {

        let item = context.inputItems[0] as! NSExtensionItem
        let message = item.userInfo?[SFExtensionMessageKey]
        
        let TeamIdentifierPrefix =
            Bundle.main.infoDictionary!["TeamIdentifierPrefix"] as! String
        
        let defaults = UserDefaults(suiteName: TeamIdentifierPrefix)
        
        let messageDictionary = message as? [String: String]
        if messageDictionary?["message"] == "getDefaults" {
            
            let codeSize = defaults?.integer(forKey: "codeSize") ?? 190
            let showHostname = defaults?.bool(forKey: "urlToggle") ?? true
            let referralToggle = defaults?.bool(forKey: "referralToggle") ?? false
            
            let response = NSExtensionItem()
            response.userInfo = [ SFExtensionMessageKey: [ "codeSize": codeSize, "showHostname": showHostname, "referralToggle": referralToggle ] ]
            context.completeRequest(returningItems: [response], completionHandler: nil)
        }
    }
}

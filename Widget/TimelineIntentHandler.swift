//
//  TimelineIntentHandler.swift
//  Widget Mac
//
//  Created by Shawn Davis on 4/21/23.
//

import Intents
import CoreData

class IntentHandler: INExtension, TimelineConfigurationIntentHandling {
    
    var moc = Persistence.shared.container.viewContext
    
    func provideQrcodeOptionsCollection(for intent: TimelineConfigurationIntent, with completion: @escaping (INObjectCollection<QRCodeIntentType>?, Error?) -> Void) {
        guard let allModels = try? Persistence.shared.getAllQREntities() else { return }
        
        let intentItems = allModels.compactMap({
            QRCodeIntentType(
                identifier: $0.objectID.uriRepresentation().absoluteString,
                display: $0.title ?? "QR Code")
        })
        
        let collection = INObjectCollection(items: intentItems)
        completion(collection, nil)
    }
    
    override func handler(for intent: INIntent) -> Any {
        return self
    }
    
}

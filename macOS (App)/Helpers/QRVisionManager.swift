//
//  QRVisionManager.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/26/21.
//

import Foundation
import SwiftUI
import Combine

class QRVisionManager: ObservableObject {
    @Published var result: String = ""
    let objectWillChange = ObservableObjectPublisher()
    
    func qrVisionResultsHandler(string: String) {
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
            self?.result = string
            print(self?.result ?? "Self has been garbage collected")
        }
    }
}

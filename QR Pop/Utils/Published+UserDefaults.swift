//
//  Published+UserDefaults.swift
//  QR Pop
//
//  Victor Kushnerov CC BY-SA 4.0
//  Source: https://stackoverflow.com/a/57982560/20422552
//  Modified by Shawn Davis on 4/12/2023
//

import SwiftUI
import Combine

fileprivate var cancellables = [String : AnyCancellable] ()

public extension Published {
    
    init(wrappedValue defaultValue: Value, _ key: String, store: UserDefaults = UserDefaults.standard) {
        let value = store.object(forKey: key) as? Value ?? defaultValue
        self.init(initialValue: value)
        cancellables[key] = projectedValue.sink { val in
            UserDefaults.standard.set(val, forKey: key)
        }
    }
}

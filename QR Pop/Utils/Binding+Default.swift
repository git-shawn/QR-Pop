//
//  Binding+Default.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/15/23.
//

import SwiftUI

extension Binding {
    
    /// Safely unwraps an optional binding by falling back to a provided default value if `nil`.
    /// - Parameter defaultValue: A default value to fall back to should the binding be `nil`.
    /// - Returns: A non-optional Binding.
    func withDefault<T>(_ defaultValue: T) -> Binding<T> where Value == Optional<T> {
        return Binding<T>(get: {
            self.wrappedValue ?? defaultValue
        }, set: { newValue in
            self.wrappedValue = newValue
        })
    }
}

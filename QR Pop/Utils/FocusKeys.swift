//
//  FocusKeys.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/24/23.
//

import SwiftUI

struct FocusedPrintingKey: FocusedValueKey {
    typealias Value = Binding<Bool>
}

struct FocusedArchivingKey: FocusedValueKey {
    typealias Value = Binding<Bool>
}

extension FocusedValues {
    
    /// Binds to a `Bool` representing a *Printing* action.
    var printing: FocusedPrintingKey.Value? {
        get { self[FocusedPrintingKey.self] }
        set { self[FocusedPrintingKey.self] = newValue }
    }
    
    /// Binds to a `Bool` representing a *Save to Archive* action.
    var archiving: FocusedArchivingKey.Value? {
        get { self[FocusedArchivingKey.self] }
        set { self[FocusedArchivingKey.self] = newValue }
    }
}

//
//  Collection+Optional.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/21/23.
//

import Foundation

extension Collection {
    
    /// Safely returns an index from a collection using `Optionals`.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

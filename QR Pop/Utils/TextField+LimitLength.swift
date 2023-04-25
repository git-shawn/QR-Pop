//
//  TextField+LimitLength.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI

/// Limit a TextField to a specified maximum length
struct TextFieldLimitModifer: ViewModifier {
    @Binding var value: String
    var length: Int
    
    func body(content: Content) -> some View {
        content
            .onChange(of: $value.wrappedValue) {
                value = String($0.prefix(length))
            }
    }
}
extension View {
    /// Limit a String binding's size to a specified maximum length. Useful in association with Textfields.
    /// - Parameters:
    ///   - value: The String Binding to watch.
    ///   - length: The maximum length the Binding may reach.
    func limitInputLength(value: Binding<String>, length: Int) -> some View {
        self.modifier(TextFieldLimitModifer(value: value, length: length))
    }
}

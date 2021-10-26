//
//  QRPopTextViewStyle.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/24/21.
//

import SwiftUI

extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}

struct QRPopTextViewStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .textFieldStyle(PlainTextFieldStyle())
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .cornerRadius(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(NSColor.textBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke()
                            .foregroundColor(Color(NSColor.underPageBackgroundColor))
                    )
            )
    }
}

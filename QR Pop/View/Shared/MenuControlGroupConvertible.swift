//
//  MenuControlGroupConvertible.swift
//  QR Pop
//
//  Created by Shawn Davis on 5/11/23.
//

import SwiftUI

/// Creates a compact control group when available. Otherwise, just returns the children as they were.
///
/// The below example will show the  `compacMenu` control group style on supported devices
/// and a regular list of buttons on non-support devices.
/// ```
/// Menu("My Menu") {
///     MenuControlGroupConvertible {
///         Button("Item 1") {}
///         Button("Item 2") {}
///     }
/// }
/// ```
struct MenuControlGroupConvertible<Content: View>: View {
    @ViewBuilder var content: Content
    
    var body: some View {
#if os(iOS)
        if #available(iOS 16.4, *) {
            ControlGroup {
                content
            }
            .controlGroupStyle(.compactMenu)
        } else {
            content
        }
#else
        content
#endif
    }
}

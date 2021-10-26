//
//  SharePicker.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/23/21.
//

import Foundation
import Cocoa
import SwiftUI

/// Creates a Share Service in SwiftUI
/// Credit to Asperi: https://stackoverflow.com/a/60955909
struct SharePicker: NSViewRepresentable {
    @Binding var isPresented: Bool
    var sharingItems: [Any] = []

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if isPresented {
            let picker = NSSharingServicePicker(items: sharingItems)
            picker.delegate = context.coordinator

            DispatchQueue.main.async {
                picker.show(relativeTo: .zero, of: nsView, preferredEdge: .minY)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(owner: self)
    }

    class Coordinator: NSObject, NSSharingServicePickerDelegate {
        let owner: SharePicker

        init(owner: SharePicker) {
            self.owner = owner
        }

        func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?) {

            sharingServicePicker.delegate = nil
            self.owner.isPresented = false
        }
    }
}

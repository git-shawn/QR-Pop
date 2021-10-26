//
//  ContactPicker.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/23/21.
//

import Foundation
import SwiftUI
import AppKit
import Contacts
import ContactsUI

struct ContactPicker: NSViewRepresentable {
    @Binding var contact: CNContact
    @Binding var isPresented: Bool
    let picker = CNContactPicker()

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if isPresented {
            let contactStore = CNContactStore()
            contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: {success,error in
                if success {
                    DispatchQueue.main.async {
                        picker.delegate = context.coordinator
                        isPresented = false
                        picker.showRelative(to: .zero, of: nsView, preferredEdge: .minY)
                    }
                } else {
                    print(error!)
                }
            })
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(owner: self)
    }

    class Coordinator: NSObject, CNContactPickerDelegate {
        let owner: ContactPicker

        init(owner: ContactPicker) {
            self.owner = owner
        }
        
        func contactPicker(_ picker: CNContactPicker, didSelect contact: CNContact) {
            self.owner.contact = contact
            picker.close()
        }
    }
}

//
//  ContactsPicker.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI
import Contacts
import Connections

struct ContactsPicker: View {
    @FetchContactList private var contacts
    @Binding var selectedContact: CNContact?
    @State var query: String = ""
    @Environment(\.dismiss) private var dismiss
    
    init(_ selectedContact: Binding<CNContact?>) {
        _contacts = FetchContactList(
            keysToFetch: [
                .type,
                .givenName, .familyName,
                .organizationName
            ],
            sortOrder: .givenName
        )
        self._selectedContact = selectedContact
    }
    
    var body: some View {
        NavigationStack {
            List(searchResults, rowContent: { contact in
                Button(action: {
                    selectedContact = contact
                    dismiss()
                }, label: {
                    if contact.contactType == .person {
                        HStack {
                            Image(systemName: "person.crop.circle")
                                .foregroundColor(.secondary)
                            Text(contact.givenName)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            + Text(" " + contact.familyName)
                                .foregroundColor(.primary)
                        }
                        .contentShape(Rectangle())
                    } else {
                        HStack {
                            Image(systemName: "building.2.crop.circle")
                                .foregroundColor(.secondary)
                            Text(contact.organizationName)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        .contentShape(Rectangle())
                    }
                })
#if os(macOS)
                .buttonStyle(.plain)
#endif
            })
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#else
            .listStyle(.inset(alternatesRowBackgrounds: true))
            .environment(\.defaultMinListRowHeight, 36)
#endif
            .searchable(text: $query)
            .navigationTitle("Contacts")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: {
                        dismiss()
                    })
                }
            }
        }
    }
    
    var searchResults: [CNContact] {
        if query.isEmpty {
            return contacts
        } else {
            return contacts.filter { $0.givenName.lowercased().contains(query.lowercased()) || $0.familyName.lowercased().contains(query.lowercased()) || $0.organizationName.lowercased().contains(query.lowercased()) }
        }
    }
}

struct ContactsPicker_Previews: PreviewProvider {
    static var previews: some View {
        ContactsPicker(.constant(CNContact()))
    }
}

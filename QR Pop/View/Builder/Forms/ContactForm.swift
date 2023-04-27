//
//  ContactForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI
import Contacts
import QRCode

struct ContactForm: View {
    @Binding var model: BuilderModel
    
    @State private var presentingContacts: Bool = false
    @State private var presentingContactBuilder: Bool = false
    @State private var contact: CNContact?
    
    let contactsPermissions = CNContactStore.authorizationStatus(for: .contacts)
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Chose a Contact", action: {
                presentingContacts.toggle()
            })
            .buttonStyle(FormButtonStyle())
            .disabled(contactsPermissions == .denied || contactsPermissions == .restricted)
            
            Button(model.responses.allSatisfy({ $0 == "" }) ? "Create a Contact" : "Edit Contact", action: {
                presentingContactBuilder.toggle()
            })
            .buttonStyle(FormButtonStyle())
        }
        .sheet(isPresented: $presentingContacts) {
            ContactsPicker($contact)
#if os(macOS)
                .frame(minWidth: 350, minHeight: 250)
#endif
        }
        .onChange(of: contact) { _ in
            guard let contact = contact else { return }
            presentingContacts = false
            parseCNContact(contact: contact)
        }
        .sheet(isPresented: $presentingContactBuilder) {
            NavigationStack {
                ContactBuilder(formStates: $model.responses, isPresented: $presentingContactBuilder)
                    .navigationTitle("New Contact")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close", role: .cancel, action: {
                                presentingContactBuilder.toggle()
                            })
                        }
                        
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Submit", action: {
                                presentingContactBuilder.toggle()
                                model.result = "BEGIN:VCARD\nVERSION:3.0\nN:\(model.responses[1]);\(model.responses[0]);;;\nFN:\(model.responses[0]) \(model.responses[1])\nORG:\(model.responses[2])\nTEL;CELL:\(model.responses[3])\nADR;TYPE#HOME:;;\(model.responses[5])\nEMAIL:\(model.responses[4])\nURL:\(model.responses[6])\nEND:VCARD"
                                
                            })
                            .foregroundColor(.accentColor)
                        }
                    }
            }
#if os(macOS)
            .frame(minWidth: 350, minHeight: 250)
#endif
        }
    }
    
    /// Generate a vCard from a Contact.
    /// - Parameter contact: The contact to transform into a vCard.
    /// - Returns: The vCard data as a String. If error, returns nil.
    private func parseCNContact(contact: CNContact) {
        let contactStore = CNContactStore()
        var fetchedContact = contact
        
        do {
            try fetchedContact = contactStore.unifiedContact(withIdentifier: contact.identifier, keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
        } catch let error {
            debugPrint(error)
            return
        }
        
        model.responses[0] = fetchedContact.givenName
        model.responses[1] = fetchedContact.familyName
        model.responses[2] = fetchedContact.organizationName
        model.responses[3] = fetchedContact.phoneNumbers.first?.value.stringValue ?? ""
        model.responses[4] = fetchedContact.emailAddresses.first?.value as? String ?? ""
        if let postalAddress = fetchedContact.postalAddresses.first?.value {
            model.responses[5] = "\(postalAddress.street), \(postalAddress.city), \(postalAddress.state) \(postalAddress.postalCode)"
        }
        model.responses[6] = fetchedContact.urlAddresses.first?.value as? String ?? ""
        
        model.result = "BEGIN:VCARD\nVERSION:3.0\nN:\(model.responses[1]);\(model.responses[0]);;;\nFN:\(model.responses[0]) \(model.responses[1])\nORG:\(model.responses[2])\nTEL;CELL:\(model.responses[3])\nADR;TYPE#HOME:;;\(model.responses[5])\nEMAIL:\(model.responses[4])\nURL:\(model.responses[6])\nEND:VCARD"
    }
}

//MARK: - Contact Builder Sheet

private struct ContactBuilder: View {
    @Binding var formStates: [String]
    @Binding var isPresented: Bool
    
    /// TextField focus information
    private enum Field: Hashable {
        case firstName
        case lastName
        case org
        case phoneNumber
        case emailAddress
        case address
        case website
    }
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack(alignment: .center, spacing: 10) {
                    VStack {
                        TextField("First Name", text: $formStates[0])
                            .textFieldStyle(FormTextFieldStyle())
                            .focused($focusedField, equals: .firstName)
                            .submitLabel(.next)
#if os(iOS)
                            .textContentType(.givenName)
                            .onSubmit {
                                focusedField = .lastName
                            }
#endif
                    }
                    
                    VStack {
                        TextField("Last Name", text: $formStates[1])
                            .textFieldStyle(FormTextFieldStyle())
                            .focused($focusedField, equals: .lastName)
                            .submitLabel(.next)
#if os(iOS)
                            .textContentType(.familyName)
                            .onSubmit {
                                focusedField = .org
                            }
#endif
                    }
                }
                
                TextField("Organization", text: $formStates[2])
                    .textFieldStyle(FormTextFieldStyle())
                    .focused($focusedField, equals: .org)
#if os(iOS)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .phoneNumber
                    }
#endif
                
                TextField("Phone Number", text: $formStates[3])
                    .textFieldStyle(FormTextFieldStyle())
                    .focused($focusedField, equals: .phoneNumber)
#if os(iOS)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .emailAddress
                    }
#endif
                TextField("Email Address", text: $formStates[4])
                    .textFieldStyle(FormTextFieldStyle())
                    .focused($focusedField, equals: .emailAddress)
#if os(iOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .address
                    }
#endif
                TextField("Address", text: $formStates[5])
                    .textFieldStyle(FormTextFieldStyle())
                    .focused($focusedField, equals: .address)
                    .submitLabel(.next)
#if os(iOS)
                    .textContentType(.fullStreetAddress)
                    .onSubmit {
                        focusedField = .website
                    }
#endif
                TextField("Website", text: $formStates[6])
                    .textFieldStyle(FormTextFieldStyle())
                    .focused($focusedField, equals: .website)
                    .disableAutocorrection(true)
#if os(iOS)
                    .keyboardType(.URL)
                    .submitLabel(.done)
                    .autocapitalization(.none)
#endif
            }
            .padding()
        }
        .background(Color.groupedBackground)
#if os(iOS)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard, content: {
                Spacer()
                Button("Done", action: {focusedField = nil})
            })
        }
#endif
    }
}

struct ContactForm_Preview: PreviewProvider {
    static var previews: some View {
        ContactForm(model: .constant(BuilderModel(for: .contact)))
        ContactBuilder(formStates: .constant([String](repeating: "", count: 7)), isPresented: .constant(true))
    }
}
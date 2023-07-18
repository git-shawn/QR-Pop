//
//  ContactForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI
import Contacts
import OSLog

struct ContactForm: View {
    @Binding var model: BuilderModel
    @EnvironmentObject var sceneModel: SceneModel
    @StateObject var engine: FormStateEngine
    
    @State private var presentingContacts: Bool = false
    @State private var presentingContactBuilder: Bool = false
    @State private var contact: CNContact?
    
    let contactsPermissions = CNContactStore.authorizationStatus(for: .contacts)
    
    init(model: Binding<BuilderModel>) {
        self._model = model
        
        if model.wrappedValue.responses.isEmpty {
            self._engine = .init(wrappedValue: .init(initial: [String](repeating: "", count: 7)))
        } else {
            self._engine = .init(wrappedValue: .init(initial: model.wrappedValue.responses))
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Chose a Contact", action: {
                presentingContacts.toggle()
            })
            .buttonStyle(FormButtonStyle())
            .disabled(contactsPermissions == .denied || contactsPermissions == .restricted)
            
            Button(engine.inputs.allSatisfy({ $0.isEmpty }) ? "Create a Contact" : "Edit Contact", action: {
                presentingContactBuilder.toggle()
            })
            .buttonStyle(FormButtonStyle())
        }
        .sheet(isPresented: $presentingContacts) {
            ContactsPicker($contact)
#if os(macOS)
                .frame(minWidth: 400, minHeight: 450)
#endif
        }
        .onReceive(engine.$outputs) {
            if model.responses != $0 {
                determineResult(for: $0)
            }
        }
        .task(id: contact) {
            if let contact = contact {
                presentingContacts = false
                parseCNContact(contact: contact)
            }
        }
        .sheet(isPresented: $presentingContactBuilder) {
            NavigationStack {
                ContactBuilder(formStates: $engine.inputs, isPresented: $presentingContactBuilder)
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
                            })
                            .foregroundColor(.accentColor)
                        }
                    }
            }
#if os(macOS)
            .frame(minWidth: 400, minHeight: 450)
#endif
        }
    }
}

//MARK: - Contact Builder Sheet

private struct ContactBuilder: View {
    @Binding var formStates: [String]
    @Binding var isPresented: Bool
    
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case firstName
        case lastName
        case org
        case phoneNumber
        case emailAddress
        case address
        case website
    }
    
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
                
                TextField("Company", text: $formStates[2])
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


// MARK: - Form Calculation

extension ContactForm: BuilderForm {
    
    func determineResult(for outputs: [String]) {
        let result = "BEGIN:VCARD\nVERSION:3.0\nN:\(outputs[1]);\(outputs[0]);;;\nFN:\(outputs[0]) \(outputs[1])\nORG:\(outputs[2])\nTEL;CELL:\(outputs[3])\nADR;TYPE#HOME:;;\(outputs[5])\nEMAIL:\(outputs[4])\nURL:\(outputs[6])\nEND:VCARD"
        
        self.model = .init(
            responses: outputs,
            result: result,
            builder: .contact)
    }
    
    /// Generate a vCard from a Contact.
    /// - Parameter contact: The contact to transform into a vCard.
    /// - Returns: The vCard data as a String. If error, returns nil.
    private func parseCNContact(contact: CNContact) {
        let contactStore = CNContactStore()
        var fetchedContact = contact
        
        do {
            try fetchedContact = contactStore.unifiedContact(withIdentifier: contact.identifier, keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
        } catch {
            Logger.logView.error("ContactForm: Unable to fetch user selected contact.")
            sceneModel.toaster = .error(note: "Could not find contact")
            return
        }
        
        engine.inputs[0] = fetchedContact.givenName
        engine.inputs[1] = fetchedContact.familyName
        engine.inputs[2] = fetchedContact.organizationName
        engine.inputs[3] = fetchedContact.phoneNumbers.first?.value.stringValue ?? ""
        engine.inputs[4] = fetchedContact.emailAddresses.first?.value as? String ?? ""
        if let postalAddress = fetchedContact.postalAddresses.first?.value {
            engine.inputs[5] = "\(postalAddress.street), \(postalAddress.city), \(postalAddress.state) \(postalAddress.postalCode)"
        }
        engine.inputs[6] = fetchedContact.urlAddresses.first?.value as? String ?? ""
    }
    
}

struct ContactForm_Preview: PreviewProvider {
    static var previews: some View {
        ContactForm(model: .constant(BuilderModel(for: .contact)))
        ContactBuilder(formStates: .constant([String](repeating: "", count: 7)), isPresented: .constant(true))
    }
}

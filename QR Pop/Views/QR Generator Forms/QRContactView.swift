//
//  QRContactView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI
import Contacts

struct QRContactView: View {
    @EnvironmentObject var qrCode: QRCode

    @State private var showPicker = false
    @State private var showBuilder = false
    @State private var contact: CNContact = CNContact()
    
    private func setCodeContent() {
        guard let vcard = vcard(contact: contact) else { return }
        qrCode.setContent(string: vcard)
    }
    
    #if os(iOS)
     /// Generate a vCard from a Contact.
     /// - Parameter contact: The contact to transform into a vCard.
     /// - Returns: The vCard data as a String. If error, returns nil.
     private func vcard(contact: CNContact) -> String? {
         var data = Data()
         let contactStore = CNContactStore()
         var fetchedContact = contact
         do {
             try fetchedContact = contactStore.unifiedContact(withIdentifier: contact.identifier, keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
         } catch {
             return nil
         }
         do {
             try (data = CNContactVCardSerialization.data(with: [fetchedContact]))
             let contactString = String(decoding: data, as: UTF8.self)
             return contactString
         } catch {
             return nil
         }
     }

    #else
    /// Generate a vCard from a Contact.
    /// - Parameter contact: The contact to transform into a vCard.
    /// - Returns: The vCard data as a String. If error, returns nil.
    private func vcard(contact: CNContact) -> String? {
        var data = Data()
        let contactStore = CNContactStore()
        var fetchedContact = contact
        do {
            try fetchedContact = contactStore.unifiedContact(withIdentifier: contact.identifier, keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
        } catch {
            return nil
        }
        do {
            try (data = CNContactVCardSerialization.data(with: [fetchedContact]))
            let contactString = String(decoding: data, as: UTF8.self)
            return contactString
        } catch {
            return nil
        }
    }
    #endif
    
    var body: some View {
        VStack(alignment: .center) {
            if (CNContactStore.authorizationStatus(for: .contacts) != .denied) {
                Button(action: {
                    showPicker = true
                }) {
                    Label("Chose a Contact", systemImage: "person.crop.circle")
                    #if os(iOS)
                        .padding(10)
                        .frame(maxWidth: 350)
                    #else
                        .overlay(ContactPicker(contact: $contact, isPresented: $showPicker))
                    #endif
                }
                #if os(iOS)
                .buttonStyle(.bordered)
                .padding(.top)
                .padding(.horizontal)
                #else
                .buttonStyle(QRPopPlainButton())
                .onChange(of: contact) { value in
                    setCodeContent()
                }
                #endif
                
                // This is a dummy view and won't appear in the UI.
                #if os(iOS)
                ContactPicker(
                    showPicker: $showPicker,
                    onSelectContact: {c in
                        self.contact = c
                    }
                ).onChange(of: contact) { value in
                    setCodeContent()
                }
                .frame(width: 0, height: 0)
                #endif
                
            } else {
                VStack(alignment: .center) {
                    Button(action: {
                        #if os(iOS)
                        guard let url = URL(string: UIApplication.openSettingsURLString) else {
                           return
                        }
                        if UIApplication.shared.canOpenURL(url) {
                           UIApplication.shared.open(url, options: [:])
                        }
                        #else
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Contacts")!)
                        #endif
                    }) {
                        Label("Allow Contact Access", systemImage: "person.crop.circle.badge.exclamationmark")
                            #if os(iOS)
                            .padding(10)
                            .frame(maxWidth: 350)
                            #endif
                    }
                    #if os(iOS)
                    .buttonStyle(.bordered)
                    .padding(.top)
                    .padding(.horizontal)
                    #else
                    .buttonStyle(QRPopPlainButton())
                    #endif
                }
            }
            
            Button(action: {
                showBuilder = true
            }) {
                Label("Create a Contact", systemImage: "person.crop.circle.badge.plus")
                #if os(iOS)
                    .padding(10)
                    .frame(maxWidth: 350)
                #endif
            }
            #if os(iOS)
            .buttonStyle(.bordered)
            .padding()
            #else
            .buttonStyle(QRPopPlainButton())
            #endif
            .sheet(isPresented: $showBuilder) {
                ModalNavbar(navigationTitle: "New Contact", showModal: $showBuilder) {
                    contactBuilder(isPresented: $showBuilder)
                }
            }
            #if os(iOS)
            Divider()
                .padding(.leading)
                .padding(.bottom)
            #endif
        }
    }
}

private struct contactBuilder: View {
    @EnvironmentObject var qrCode: QRCode
    @Binding var isPresented: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                #if os(macOS)
                Text("Contact QR Code")
                    .font(.largeTitle)
                    .bold()
                #else
                HStack {
                    Spacer()
                    Image(systemName: "person.crop.rectangle")
                        .font(.system(size: 80))
                        .foregroundColor(Color.accentColor)
                    Spacer()
                }
                #endif
                HStack(alignment: .center, spacing: 10) {
                    VStack {
                        TextField("First Name", text: $qrCode.formStates[0])
                            .textFieldStyle(QRPopTextStyle())
                        #if os(iOS)
                            .textContentType(.givenName)
                            .submitLabel(.next)
                        #endif
                    }
                    VStack {
                        TextField("Last Name", text: $qrCode.formStates[1])
                            .textFieldStyle(QRPopTextStyle())
                        #if os(iOS)
                            .textContentType(.familyName)
                            .submitLabel(.next)
                        #endif
                    }
                }
                TextField("Phone Number", text: $qrCode.formStates[2])
                    .textFieldStyle(QRPopTextStyle())
                #if os(iOS)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .submitLabel(.next)
                #endif
                TextField("Email Address", text: $qrCode.formStates[3])
                    .textFieldStyle(QRPopTextStyle())
                #if os(iOS)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .submitLabel(.next)
                #endif
                TextField("Address", text: $qrCode.formStates[4])
                    .textFieldStyle(QRPopTextStyle())
                #if os(iOS)
                    .textContentType(.fullStreetAddress)
                    .submitLabel(.next)
                #endif
                TextField("Website", text: $qrCode.formStates[5])
                    .textFieldStyle(QRPopTextStyle())
                #if os(iOS)
                    .keyboardType(.URL)
                    .submitLabel(.done)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                #endif
                HStack {
                    Spacer()
                    Button(action: {
                        let vcard = "BEGIN:VCARD\nVERSION:3.0\nN:\(qrCode.formStates[1]);\(qrCode.formStates[0]);;;\nFN:\(qrCode.formStates[0]) \(qrCode.formStates[1])\nTEL;CELL:\(qrCode.formStates[2])\nADR;TYPE#HOME:;;\(qrCode.formStates[4])\nEMAIL:\(qrCode.formStates[3])\nURL:\(qrCode.formStates[5])\nEND:VCARD"
                        qrCode.setContent(string: vcard)
                        isPresented = false
                    }) {
                        Label("Done", systemImage: "checkmark.circle")
                            #if os(iOS)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(10)
                            .frame(maxWidth: 350)
                            #endif
                    }
                    #if os(macOS)
                        .buttonStyle(QRPopProminentButton())
                    #else
                        .buttonStyle(.borderedProminent)
                    #endif
                    Spacer()
                }
            }.padding()
        }
    }
}

struct QRContactView_Previews: PreviewProvider {
    static var previews: some View {
        QRContactView()
    }
}

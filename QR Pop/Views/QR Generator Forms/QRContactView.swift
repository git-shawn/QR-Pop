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
    @State private var canGenerateCode = false
    @State private var contact: CNContact = CNContact()
    
    //Contact Builder States
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var address = ""
    @State private var website = ""
    #if os(iOS)
    private enum Field: Int, Hashable {
        case fName, lName, phoneNumber, email, address, website
    }
    @FocusState private var focusedField: Field?
    #endif
    
    private func setCodeContent() {
        if canGenerateCode {
            qrCode.generateContact(contact: contact)
        } else {
            qrCode.setContent(string: "")
        }
    }
    
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
                    canGenerateCode = true
                    setCodeContent()
                }
                #endif
                
                // This is a dummy view and won't appeaar in the UI.
                #if os(iOS)
                ContactPicker(
                    showPicker: $showPicker,
                    onSelectContact: {c in
                        self.contact = c
                    }
                ).onChange(of: contact) { value in
                    canGenerateCode = true
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
            .sheet(isPresented: $showBuilder, onDismiss: {
                let vcard = "BEGIN:VCARD\nVERSION:3.0\nN:\(lastName);\(firstName);;;\nFN:\(firstName) \(lastName)\nTEL;CELL:\(phoneNumber)\nADR;TYPE#HOME:;;\(address)\nEMAIL:\(email)\nURL:\(website)\nEND:VCARD"
                qrCode.setContent(string: vcard)
            }, content: {
                ModalNavbar(navigationTitle: "New Contact", showModal: $showBuilder) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Contact QR Code")
                                .font(.largeTitle)
                                .bold()
                            HStack(alignment: .center, spacing: 10) {
                                VStack {
                                    TextField("First Name", text: $firstName)
                                        .textFieldStyle(QRPopTextStyle())
                                    #if os(iOS)
                                        .textContentType(.givenName)
                                        .submitLabel(.next)
                                        .focused($focusedField, equals: .fName)
                                        .onSubmit {
                                            focusedField = .lName
                                        }
                                    #endif
                                }
                                VStack {
                                    TextField("Last Name", text: $lastName)
                                        .textFieldStyle(QRPopTextStyle())
                                    #if os(iOS)
                                        .textContentType(.familyName)
                                        .submitLabel(.next)
                                        .focused($focusedField, equals: .lName)
                                        .onSubmit {
                                            focusedField = .phoneNumber
                                        }
                                    #endif
                                }
                            }
                            TextField("Phone Number", text: $phoneNumber)
                                .textFieldStyle(QRPopTextStyle())
                            #if os(iOS)
                                .keyboardType(.phonePad)
                                .textContentType(.telephoneNumber)
                                .submitLabel(.next)
                                .focused($focusedField, equals: .phoneNumber)
                                .onSubmit {
                                    focusedField = .email
                                }
                            #endif
                            TextField("Email Address", text: $email)
                                .textFieldStyle(QRPopTextStyle())
                            #if os(iOS)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .submitLabel(.next)
                                .focused($focusedField, equals: .email)
                                .onSubmit {
                                    focusedField = .address
                                }
                            #endif
                            TextField("Address", text: $address)
                                .textFieldStyle(QRPopTextStyle())
                            #if os(iOS)
                                .textContentType(.fullStreetAddress)
                                .submitLabel(.next)
                                .focused($focusedField, equals: .address)
                                .onSubmit {
                                    focusedField = .website
                                }
                            #endif
                            TextField("Website", text: $website)
                                .textFieldStyle(QRPopTextStyle())
                            #if os(iOS)
                                .keyboardType(.URL)
                                .submitLabel(.done)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .focused($focusedField, equals: .website)
                                .onSubmit {
                                    focusedField = nil
                                }
                            #endif
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                    showBuilder = false
                                }) {
                                    Label("Done", systemImage: "checkmark.circle")
                                        #if os(iOS)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .frame(maxWidth: 350)
                                        .background(Color.accentColor)
                                        .cornerRadius(10)
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
            })
            #if os(iOS)
            Divider()
                .padding(.leading)
                .padding(.bottom)
            #endif
        }.onChange(of: qrCode.codeContent, perform: {value in
            if (value.isEmpty) {
                contact = CNContact()
                canGenerateCode = false
                firstName = ""
                lastName = ""
                phoneNumber = ""
                email = ""
                address = ""
                website = ""
            }
        })
    }
}

struct QRContactView_Previews: PreviewProvider {
    static var previews: some View {
        QRContactView()
    }
}

//
//  ContactBuilder.swift
//  QR Pop
//
//  Created by Shawn Davis on 8/12/23.
//

import SwiftUI
import Contacts
import CoreLocation
import OSLog

struct ContactBuilder: View {
    @Binding var vcard: String
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var company: String = ""
    @State private var birthday: Date?
    @State private var phoneNumbers: [DynamicPhoneField] = []
    @State private var emails: [DynamicListField] = []
    @State private var urls: [DynamicListField] = []
    @State private var addresses: [DynamicAddressField] = []
    @StateObject private var mapSearch = LocationSearchCompleter()
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var sceneModel: SceneModel

    
    init(vcard: Binding<String>) {
        self._vcard = vcard
        if !self.vcard.isEmpty,
           let data = self.vcard.data(using: .utf8)
        {
            do {
                let contact = try CNContactVCardSerialization.contacts(with: data).first
                self._firstName = State(initialValue: contact?.givenName ?? "")
                self._lastName = State(initialValue: contact?.familyName ?? "")
                self._company = State(initialValue: contact?.organizationName ?? "")
                self._birthday = State(initialValue: contact?.birthday?.date)
                
                self._phoneNumbers = State(initialValue: contact?.phoneNumbers.compactMap {
                    let label = CNLabeledValue<NSString>.localizedString(forLabel: $0.label ?? "").lowercased()
                    if let kind = DynamicPhoneFieldType(rawValue: label) {
                        return DynamicPhoneField(number: $0.value.stringValue, kind: kind)
                    } else {
                        return nil
                    }
                } ?? [])
                
                self._emails = State(initialValue: contact?.emailAddresses.compactMap {
                    let label = CNLabeledValue<NSString>.localizedString(forLabel: $0.label ?? "").lowercased()
                    if let kind = DynamicListFieldType(rawValue: label) {
                        return DynamicListField(value: $0.value as String, kind: kind)
                    } else {
                        return nil
                    }
                } ?? [])
                
                self._urls = State(initialValue: contact?.urlAddresses.compactMap {
                    let label = CNLabeledValue<NSString>.localizedString(forLabel: $0.label ?? "").lowercased()
                    if let kind = DynamicListFieldType(rawValue: label) {
                        return DynamicListField(value: $0.value as String, kind: kind)
                    } else {
                        return nil
                    }
                } ?? [])
                
                self._addresses = State(initialValue: contact?.postalAddresses.compactMap {
                    let label = CNLabeledValue<NSString>.localizedString(forLabel: $0.label ?? "").lowercased()
                    if let kind = DynamicListFieldType(rawValue: label) {
                        return DynamicAddressField(value: CNPostalAddressFormatter.string(from: $0.value, style: .mailingAddress), postalAddress: $0.value, kind: kind)
                    } else {
                        return nil
                    }
                } ?? [])
            } catch {
                Logger.logView.warning("ContactBuilder: The initial vcard value was not empty, yet could not be serialized.")
            }
        }
    }
    
    
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    Spacer()
                    Image(systemName: ((firstName.isEmpty && lastName.isEmpty && !company.isEmpty) ? "building.2.crop.circle.fill" : "person.crop.circle.fill"))
                        .resizable()
                        .scaledToFit()
                        .symbolRenderingMode(.multicolor)
                        .frame(width: 96, height: 96)
                        .foregroundStyle(Color.gray.gradient)
                    Spacer()
#if os(macOS)
    .padding(.top)
#endif
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                Section {
                    TextField("First Name", text: $firstName)
#if os(iOS)
                        .textContentType(.givenName)
#endif
                    TextField("Last Name", text: $lastName)
#if os(iOS)
                        .textContentType(.familyName)
#endif
                    TextField("Company", text: $company)
#if os(iOS)
                        .textContentType(.organizationName)
#endif
                }
                
                Section {
                    if birthday == nil {
                        Button(action: {
                            withAnimation(.spring()) {
                                birthday = Date()
                            }
                        }, label: {
                            Label(title: {
                                Text("add birthday")
                                    .foregroundColor(.primary)
                            }, icon: {
                                Image(systemName: "plus.circle.fill")
                                    .imageScale(.large)
                                    .foregroundColor(.green)
                            })
                        })
#if os(macOS)
                        .padding(.top, 10)
                        .buttonStyle(.plain)
#endif
                    } else {
                        HStack {
                            Button(action: {
                                withAnimation(.spring()) {
                                    birthday = nil
                                }
                            }, label: {
                                Label(title: {
                                    Text("remove birthday")
                                        .foregroundColor(.primary)
                                }, icon: {
                                    Image(systemName: "minus.circle.fill")
                                        .imageScale(.large)
                                        .foregroundColor(.red)
                                })
                                .labelStyle(.iconOnly)
                            })
#if os(macOS)
                            .buttonStyle(.plain)
#endif
                            
                            DatePicker(selection: $birthday.withDefault(Date()), displayedComponents: .date, label: {
                                HStack {
                                    Text("birthday")
                                        .padding(.leading)
                                    Divider()
                                }
                            })
                        }
                        #if os(macOS)
                        .padding(.top, 10)
                        #endif
                    }
#if os(macOS)
                    Divider()
#endif
                }
                
                Group {
                    DynamicPhoneList(phones: $phoneNumbers)
#if os(macOS)
                    Divider()
#endif
                    DynamicGenericList(name: "Email", fields: $emails)
#if os(iOS)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
#endif
#if os(macOS)
                    Divider()
#endif
                    DynamicGenericList(name: "URL", fields: $urls)
#if os(iOS)
                        .keyboardType(.URL)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
#endif
#if os(macOS)
                    Divider()
#endif
                    DynamicAddressList(fields: $addresses)
                    #if os(macOS)
                        .padding(.bottom)
                    #endif
                }
            }
#if os(iOS)
            .listStyle(.grouped)
            .environment(\.editMode, .constant(.active))
            .navigationBarTitleDisplayMode(.inline)
#else
            .listStyle(.plain)
            .textFieldStyle(ContactBuilderTextFieldStyle())
            .frame(width: 400, height: 350)
#endif
            .navigationTitle("New Contact")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        do {
                            vcard = try vCard.sanitarySerialization(of: buildContact())
                            dismiss()
                        } catch {
                            dismiss()
                            sceneModel.toaster = .error(note: "Contact not created")
                            Logger.logView.error("ContactBuilder: Could not serialize/sanitize CNMutableContact")
                        }
                    }
                    .disabled(firstName.isEmpty && lastName.isEmpty && company.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func buildContact() -> CNMutableContact {
        let contact = CNMutableContact()
        
        contact.givenName = firstName
        contact.familyName = lastName
        contact.organizationName = company
        if let birthday = birthday {
            contact.birthday = Calendar.current.dateComponents([.year, .month, .day], from: birthday)
        }
        
        contact.phoneNumbers = phoneNumbers.map {
            CNLabeledValue(label: $0.kind.name, value: CNPhoneNumber(stringValue: $0.number))
        }
        
        contact.emailAddresses = emails.map {
            CNLabeledValue(label: $0.kind.name, value: $0.value as NSString)
        }
        
        contact.urlAddresses = urls.map {
            CNLabeledValue(label: $0.kind.name, value: $0.value as NSString)
        }
        
        contact.postalAddresses = addresses.map {
            return CNLabeledValue(label: $0.kind.name, value: $0.postalAddress)
        }
        
        return contact
    }
}

// MARK: - Generic Struct

private struct DynamicGenericList: View {
    let name: String
    @Binding var fields: [DynamicListField]
    
    var body: some View {
        Section {
            if fields.isEmpty {
                Button(action: {
                    withAnimation(.spring()) {
                        fields = [.init(value: "", kind: .home)]
                    }
                }, label: {
                    Label(title: {
                        Text("add \(name.lowercased())")
                            .foregroundColor(.primary)
                    }, icon: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                            .foregroundColor(.green)
                    })
                })
#if os(macOS)
                .buttonStyle(.plain)
#endif
            } else {
                ForEach(Array(fields.enumerated()), id: \.offset) { index, field in
                    HStack {
                        HStack {
                            Spacer()
                            Menu(content: {
                                Button("home", action: {
                                    fields[index].kind = .home
                                })
                                .disabled(fields.contains(where: {$0.kind == .home}))
#if os(macOS)
                                .buttonStyle(.plain)
#endif
                                
                                Button("work", action: {
                                    fields[index].kind = .work
                                })
                                .disabled(fields.contains(where: {$0.kind == .work}))
#if os(macOS)
                                .buttonStyle(.plain)
#endif
                                
                            }, label: {
                                HStack {
                                    Text(field.kind.name)
#if os(iOS)
                                    Image(systemName: "chevron.forward")
                                        .imageScale(.small)
                                        .foregroundColor(.secondary)
#endif
                                }
                            })
                            
                            Divider()
                        }
#if os(iOS)
                        .frame(maxWidth: 80)
#else
                        .frame(maxWidth: 120)
#endif
                        
                        TextField(name, text: $fields[index].value)
#if os(iOS)
                            .textInputAutocapitalization(.never)
#endif
                    }
                }
                .onDelete(perform: {index in
                    fields.remove(atOffsets: index)
                })
                
                if fields.count < 2 {
                    Button(action: {
                        withAnimation(.spring()) {
                            if fields.contains(where: {$0.kind == .home}) {
                                fields.append(.init(value: "", kind: .work))
                            } else {
                                fields.append(.init(value: "", kind: .home))
                            }
                        }
                    }, label: {
                        Label(title: {
                            Text("add \(name.lowercased())")
                                .foregroundColor(.primary)
                        }, icon: {
                            Image(systemName: "plus.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(.green)
                        })
                    })
#if os(macOS)
                    .buttonStyle(.plain)
#endif
                }
            }
        }
    }
}


// MARK: - Address Struct

private struct DynamicAddressList: View {
    @Binding var fields: [DynamicAddressField]
    @FocusState private var isFocused: Bool
    @EnvironmentObject var sceneModel: SceneModel
    
    var body: some View {
        Section {
            if fields.isEmpty {
                Button(action: {
                    withAnimation(.spring()) {
                        fields = [.init(value: "", postalAddress: CNPostalAddress(), kind: .home)]
                    }
                }, label: {
                    Label(title: {
                        Text("add address")
                            .foregroundColor(.primary)
                    }, icon: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                            .foregroundColor(.green)
                    })
                })
#if os(macOS)
                .buttonStyle(.plain)
#endif
            } else {
                ForEach(Array(fields.enumerated()), id: \.offset) { index, field in
                    HStack {
                        HStack {
                            Spacer()
                            Menu(content: {
                                Button("home", action: {
                                    fields[index].kind = .home
                                })
                                .disabled(fields.contains(where: {$0.kind == .home}))
#if os(macOS)
                                .buttonStyle(.plain)
#endif
                                
                                Button("work", action: {
                                    fields[index].kind = .work
                                })
                                .disabled(fields.contains(where: {$0.kind == .work}))
#if os(macOS)
                                .buttonStyle(.plain)
#endif
                                
                            }, label: {
                                HStack {
                                    Text(field.kind.name)
#if os(iOS)
                                    Image(systemName: "chevron.forward")
                                        .imageScale(.small)
                                        .foregroundColor(.secondary)
#endif
                                }
                            })
                            
                            Divider()
                        }
#if os(iOS)
                        .frame(maxWidth: 80)
#else
                        .frame(maxWidth: 120)
#endif
                        TextField("\naddress", text: $fields[index].value, axis: .vertical)
                            .lineLimit(3...6)
                            .focused($isFocused)
                            .onChange(of: isFocused) { isFocused in
                                if !isFocused {
                                    let geoCoder = CLGeocoder()
                                    geoCoder.geocodeAddressString(fields[index].value) { (placemarks, error) in
                                        guard
                                            let placemarks = placemarks,
                                            let address = placemarks.first?.postalAddress
                                        else {
                                            withAnimation {
                                                fields[index].value = ""
                                            }
                                            sceneModel.toaster = .error(note: "Invalid address")
                                            return
                                        }
                                        fields[index].value = CNPostalAddressFormatter.string(from: address, style: .mailingAddress)
                                        fields[index].postalAddress = address
                                    }
                                }
                            }
#if os(iOS)
                            .textContentType(.fullStreetAddress)
#endif
                    }
                }
                .onDelete(perform: {index in
                    fields.remove(atOffsets: index)
                })
                
                if fields.count < 2 {
                    Button(action: {
                        withAnimation(.spring()) {
                            if fields.contains(where: {$0.kind == .home}) {
                                fields.append(.init(value: "", postalAddress: CNPostalAddress(), kind: .work))
                            } else {
                                fields.append(.init(value: "", postalAddress: CNPostalAddress(), kind: .home))
                            }
                        }
                    }, label: {
                        Label(title: {
                            Text("add address")
                                .foregroundColor(.primary)
                        }, icon: {
                            Image(systemName: "plus.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(.green)
                        })
                    })
#if os(macOS)
                    .buttonStyle(.plain)
#endif
                }
            }
        }
    }
}

// MARK: - Phone Struct

private struct DynamicPhoneList: View {
    @Binding var phones: [DynamicPhoneField]
    
    var body: some View {
        Section {
            if phones.isEmpty {
                Button(action: {
                    withAnimation(.spring()) {
                        phones = [.init(number: "", kind: .cell)]
                    }
                }, label: {
                    Label(title: {
                        Text("add phone")
                            .foregroundColor(.primary)
                    }, icon: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                            .foregroundColor(.green)
                    })
                })
#if os(macOS)
                .buttonStyle(.plain)
#endif
            } else {
                ForEach(Array(phones.enumerated()), id: \.offset) { index, phone in
                    HStack {
                        HStack {
                            Spacer()
                            Menu(content: {
                                let usedTypes = GetUsedDynamicPhoneFieldTypes(for: phones)
                                ForEach(DynamicPhoneFieldType.allCases, id: \.self) { type in
                                    Button(type.name, action: {
                                        phones[index].kind = type
                                    })
                                    .disabled(usedTypes.contains(type))
#if os(macOS)
                                    .buttonStyle(.plain)
#endif
                                }
                            }, label: {
                                HStack {
                                    Text(phone.kind.name)
#if os(iOS)
                                    Image(systemName: "chevron.forward")
                                        .imageScale(.small)
                                        .foregroundColor(.secondary)
#endif
                                }
                            })
                            
                            Divider()
                        }
#if os(iOS)
                        .frame(maxWidth: 80)
#else
                        .frame(maxWidth: 120)
#endif
                        
                        TextField("Phone", text: $phones[index].number)
#if os(iOS)
                            .keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
#endif
                    }
                }
                .onDelete(perform: {index in
                    phones.remove(atOffsets: index)
                })
                
                let usedTypes = GetUsedDynamicPhoneFieldTypes(for: phones)
                if usedTypes.count < 5 {
                    Button(action: {
                        withAnimation(.spring()) {
                            phones.append(.init(number: "", kind: GetRandomAvailablePhoneFieldType(usedTypes: usedTypes)))
                        }
                    }, label: {
                        Label(title: {
                            Text("add phone")
                                .foregroundColor(.primary)
                        }, icon: {
                            Image(systemName: "plus.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(.green)
                        })
                    })
#if os(macOS)
                    .buttonStyle(.plain)
#endif
                }
            }
        }
    }
}

// MARK: - Phone Numbers

private struct DynamicPhoneField: Hashable {
    var number: String
    var kind: DynamicPhoneFieldType
}

/// Acceptable vCard Paramter Values for a `TEL` as defined by IANA.
/// [Source](https://www.iana.org/assignments/vcard-elements/vcard-elements.xhtml)
private enum DynamicPhoneFieldType: CaseIterable, Equatable, Hashable {
    static var allCases: [DynamicPhoneFieldType] {
        [.home, .work, .fax, .cell, .voice]
    }
    
    static func < (lhs: DynamicPhoneFieldType, rhs: DynamicPhoneFieldType) -> Bool {
        lhs.name < rhs.name
    }
    
    case home
    case work
    case fax
    case cell
    case voice
    case other(String)
    
    var name: String {
        switch self {
        case .home:
            return "home"
        case .work:
            return "work"
        case .fax:
            return "fax"
        case .cell:
            return "cell"
        case .voice:
            return "voice"
        case .other(let string):
            return string
        }
    }
    
    init?(rawValue: String) {
        if rawValue == "home" { self = .home }
        else if rawValue == "work" { self = .work }
        else if rawValue == "fax" { self = .fax }
        else if rawValue == "cell" || rawValue == "mobile" { self = .cell}
        else if rawValue == "voice" { self = .voice }
        else { self = .other(rawValue) }
    }
}

/// A function that returns an unused `DynamicPhoneFieldType` based on a
/// given collection of used `DynamicPhoneFieldTypes`.
/// - Parameter usedTypes: An array of `DynamicPhoneFieldType` elements to exclude.
/// - Returns: A `DynamicPhoneFieldType` not included in the given array.
private func GetRandomAvailablePhoneFieldType(usedTypes: [DynamicPhoneFieldType]) -> DynamicPhoneFieldType {
    let availableTypes = DynamicPhoneFieldType.allCases.filter { !usedTypes.contains($0) }
    return availableTypes.first!
}

/// An array of all `DynamicPhoneFieldType` elements contained
/// within an array of `DynamicPhoneField` elements.
/// - Parameter fields: An array of `DynamicPhoneField` elements.
/// - Returns: An array of `DynamicPhoneFieldType` elements contained within a given array.
private func GetUsedDynamicPhoneFieldTypes(for fields: [DynamicPhoneField]) -> [DynamicPhoneFieldType] {
    var usedTypes: [DynamicPhoneFieldType] = []
    for field in fields {
        usedTypes.append(field.kind)
    }
    return usedTypes
}

// MARK: - 0ther Dynamic Fields

private struct DynamicListField: Hashable {
    var value: String
    var kind: DynamicListFieldType
}

private struct DynamicAddressField: Hashable {
    var value: String
    var postalAddress: CNPostalAddress
    var kind: DynamicListFieldType
}

private enum DynamicListFieldType: CaseIterable, Hashable, Equatable {
    static var allCases: [DynamicListFieldType] {
        [.home, .work]
    }
    
    static func < (lhs: DynamicListFieldType, rhs: DynamicListFieldType) -> Bool {
        lhs.name < rhs.name
    }
    
    case home
    case work
    case other(String)
    
    var name: String {
        switch self {
        case .home:
            return "home"
        case .work:
            return "work"
        case .other(let string):
            return string
        }
    }
    
    init?(rawValue: String) {
        if rawValue == "home" || rawValue == "homepage" { self = .home }
        else if rawValue == "work" { self = .work }
        else { self = .other(rawValue) }
    }
}

struct ContactBuilder_Previews: PreviewProvider {
    static var previews: some View {
        ContactBuilder(vcard: .constant(""))
    }
}

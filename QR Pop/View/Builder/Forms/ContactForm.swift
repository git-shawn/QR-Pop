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
            self._engine = .init(wrappedValue: .init(initial: [""]))
        } else if model.wrappedValue.responses.count == 1 {
            self._engine = .init(wrappedValue: .init(initial: model.wrappedValue.responses))
        } else {
            // Migrate to the new contact format...
            let vcard = "BEGIN:VCARD\nVERSION:3.0\nN:\(model.wrappedValue.responses[1]);\(model.wrappedValue.responses[0]);;;\nFN:\(model.wrappedValue.responses[0]) \(model.wrappedValue.responses[1])\nORG:\(model.wrappedValue.responses[2])\nTEL;CELL:\(model.wrappedValue.responses[3])\nADR;TYPE#HOME:;;\(model.wrappedValue.responses[5])\nEMAIL:\(model.wrappedValue.responses[4])\nURL:\(model.wrappedValue.responses[6])\nEND:VCARD"
            
            self._engine = .init(wrappedValue: .init(initial: [vcard]))
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
        }
        .sheet(isPresented: $presentingContactBuilder) {
            ContactBuilder(vcard: $engine.inputs[0])
        }
        .onReceive(engine.$outputs) {
            if model.responses != $0 {
                determineResult(for: $0)
            }
        }
        .task(id: contact) {
            if let contact = contact {
                presentingContacts = false
                do {
                    engine.inputs[0] = try vCard.sanitarySerialization(of: contact)
                } catch {
                    Logger.logView.error("ContactForm: CNContact could not be serialized/sanitized.")
                }
            }
        }
    }
}

// MARK: - Form Calculation

extension ContactForm: BuilderForm {
    
    func determineResult(for outputs: [String]) {
        self.model = .init(
            responses: outputs,
            result: outputs[0],
            builder: .contact)
    }
}

struct ContactForm_Preview: PreviewProvider {
    static var previews: some View {
        ContactForm(model: .constant(BuilderModel(for: .contact)))
    }
}

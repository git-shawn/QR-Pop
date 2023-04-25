//
//  MailForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI

struct MailForm: View {
    @Binding var model: BuilderModel
    
    /// TextField focus information
    private enum Field: Hashable {
        case email
        case subject
        case body
    }
    @FocusState private var focusedField: Field?
    
    @State private var writeFullScreen: Bool = false
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 20) {
                TextField("Email Address", text: $model.responses[0])
                    .autocorrectionDisabled(true)
                    .textFieldStyle(FormTextFieldStyle())
                    .focused($focusedField, equals: .email)
#if os(iOS)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .subject
                    }
#endif
                TextField("Subject", text: $model.responses[1])
                    .textFieldStyle(FormTextFieldStyle())
                    .focused($focusedField, equals: .subject)
                    .autocorrectionDisabled(true)
#if os(iOS)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .body
                    }
#endif
                TextField("Message", text: $model.responses[2], axis: .vertical)
                    .lineLimit(6, reservesSpace: true)
                    .textFieldStyle(FormTextFieldStyle())
                    .focused($focusedField, equals: .body)
                    .limitInputLength(value: $model.responses[2], length: 1500)
                    .submitLabel(.return)
                    .textEditor("Email Body", text: $model.responses[2], isPresented: $writeFullScreen)
                    .id(Field.body)
            }
            .onChange(of: model.responses, debounce: 1) {_ in
                determineResult()
            }
#if os(iOS)
            .onChange(of: focusedField) { field in
                if field == .body {
                    withAnimation {
                        proxy.scrollTo(Field.body, anchor: .center)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard, content: {
                    if focusedField == .body {
                        Button(action: {
                            writeFullScreen.toggle()
                        }, label: {
                            Label("Make Textfield Fullscreen", systemImage: "arrow.up.backward.and.arrow.down.forward.circle")
                        })
                    }
                    Spacer()
                    Button("Done", action: {focusedField = nil})
                })
            }
#endif
        }
    }
}

// MARK: - Form Calculation

extension MailForm {
    
    func determineResult() {
        model.result = "mailto:\(model.responses[0])?subject=\(model.responses[1])&body=\(model.responses[2])"
    }
}

struct MailForm_Previews: PreviewProvider {
    static var previews: some View {
        MailForm(model: .constant(BuilderModel(for: .email)))
    }
}

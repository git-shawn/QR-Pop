//
//  MailForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI

struct MailForm: View {
    @Binding var model: BuilderModel
    @StateObject var engine: FormStateEngine
    @State private var writeFullScreen: Bool = false
    
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case email
        case subject
        case body
    }
    
    init(model: Binding<BuilderModel>) {
        self._model = model
        
        if model.wrappedValue.responses.isEmpty {
            self._engine = .init(wrappedValue: .init(initial: ["","", ""]))
        } else {
            self._engine = .init(wrappedValue: .init(initial: model.wrappedValue.responses))
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 20) {
                TextField("Email Address", text: $engine.inputs[0])
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
                TextField("Subject", text: $engine.inputs[1])
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
                TextField("Message", text: $engine.inputs[2], axis: .vertical)
                    .lineLimit(6, reservesSpace: true)
                    .textFieldStyle(FormTextFieldStyle())
                    .focused($focusedField, equals: .body)
                    .limitInputLength(value: $engine.inputs[2], length: 1500)
                    .submitLabel(.return)
                    .textEditor("Email Body", text: $engine.inputs[2], isPresented: $writeFullScreen)
                    .id(Field.body)
            }
            .onReceive(engine.$outputs) {
                if model.responses != $0 {
                    determineResult(for: $0)
                }
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

extension MailForm: BuilderForm {
    
    func determineResult(for outputs: [String]) {
        self.model = .init(
            responses: outputs,
            result: "mailto:\(outputs[0])?subject=\(outputs[1])&body=\(outputs[2])",
            builder: .email)
    }
}

struct MailForm_Previews: PreviewProvider {
    static var previews: some View {
        MailForm(model: .constant(BuilderModel(for: .email)))
    }
}

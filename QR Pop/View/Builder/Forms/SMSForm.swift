//
//  SMSForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI

struct SMSForm: View {
    @Binding var model: BuilderModel
    @StateObject var engine: FormStateEngine
    
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case phone
        case message
    }
    
    init(model: Binding<BuilderModel>) {
        self._model = model
        
        if model.wrappedValue.responses.isEmpty {
            self._engine = .init(wrappedValue: .init(initial: ["", ""]))
        } else {
            self._engine = .init(wrappedValue: .init(initial: model.wrappedValue.responses))
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 20) {
                TextField("Phone Number", text: $engine.inputs[0])
                    .autocorrectionDisabled(true)
                    .textFieldStyle(FormTextFieldStyle())
                    .focused($focusedField, equals: .phone)
#if os(iOS)
                    .keyboardType(.phonePad)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .message
                    }
#endif
                TextField("Message", text: $engine.inputs[1], axis: .vertical)
                    .lineLimit(6, reservesSpace: true)
                    .textFieldStyle(FormTextFieldStyle())
                    .focused($focusedField, equals: .message)
                    .submitLabel(.done)
                    .limitInputLength(value: $engine.inputs[1], length: 160)
                    .id(Field.message)
            }
            .onReceive(engine.$outputs) {
                if model.responses != $0 {
                    determineResult(for: $0)
                }
            }
#if os(iOS)
            .onChange(of: focusedField) { field in
                if field == .message {
                    withAnimation {
                        proxy.scrollTo(Field.message, anchor: .center)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard, content: {
                    if focusedField == .message {
                        Spacer()
                        Text("\(engine.inputs[1].count)/160")
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

extension SMSForm: BuilderForm {
    func determineResult(for outputs: [String]) {
        self.model = .init(
            responses: outputs,
            result: "smsto:\(outputs[0]):\(outputs[1])",
            builder: .sms)
    }
    
}

struct SMSForm_Previews: PreviewProvider {
    static var previews: some View {
        SMSForm(model: .constant(BuilderModel(for: .sms)))
    }
}

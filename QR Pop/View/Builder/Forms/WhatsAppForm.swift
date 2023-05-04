//
//  WhatsAppForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/5/23.
//

import SwiftUI

struct WhatsAppForm: View {
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
            self._engine = .init(wrappedValue: .init(initial: ["",""]))
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
            .onChange(of: focusedField) { field in
                if field == .message {
                    withAnimation {
                        proxy.scrollTo(Field.message, anchor: .center)
                    }
                }
            }
            .onReceive(engine.$outputs) {
                if model.responses != $0 {
                    determineResult(for: $0)
                }
            }
#if os(iOS)
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

extension WhatsAppForm: BuilderForm {
    
    func determineResult(for outputs: [String]) {
        self.model = .init(
            responses: outputs,
            result: "https://api.whatsapp.com/send?phone=\(outputs[0])\(outputs[1].isEmpty ? "" : "&text=\(outputs[1])")",
            builder: .whatsapp)
    }
}

struct WhatsAppForm_Previews: PreviewProvider {
    static var previews: some View {
        WhatsAppForm(model: .constant(BuilderModel(for: .whatsapp)))
    }
}

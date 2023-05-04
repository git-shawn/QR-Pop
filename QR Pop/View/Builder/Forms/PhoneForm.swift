//
//  PhoneForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI

struct PhoneForm: View {
    @Binding var model: BuilderModel
    @StateObject var engine: FormStateEngine
    
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case phone
    }
    
    init(model: Binding<BuilderModel>) {
        self._model = model
        
        if model.wrappedValue.responses.isEmpty {
            self._engine = .init(wrappedValue: .init(initial: [""]))
        } else {
            self._engine = .init(wrappedValue: .init(initial: model.wrappedValue.responses))
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Phone Number", text: $engine.inputs[0])
#if os(iOS)
                .keyboardType(.phonePad)
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
#endif
                .autocorrectionDisabled(true)
                .textFieldStyle(FormTextFieldStyle())
                .focused($focusedField, equals: .phone)
        }
        .onReceive(engine.$outputs) {
            if model.responses != $0 {
                determineResult(for: $0)
            }
        }
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

extension PhoneForm: BuilderForm {
    
    func determineResult(for outputs: [String]) {
        self.model = .init(
            responses: outputs,
            result: outputs[0],
            builder: .phone)
    }
}

struct PhoneForm_Previews: PreviewProvider {
    static var previews: some View {
        PhoneForm(model: .constant(BuilderModel(for: .phone)))
    }
}

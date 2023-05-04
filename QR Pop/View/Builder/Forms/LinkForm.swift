//
//  LinkForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/24/22.
//

import SwiftUI

struct LinkForm: View {
    @Binding var model: BuilderModel
    @StateObject var engine: FormStateEngine
    
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case url
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
            TextField("Enter URL", text: $engine.inputs[0])
                .textFieldStyle(FormTextFieldStyle())
                .autocorrectionDisabled(true)
                .focused($focusedField, equals: .url)
#if os(iOS)
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
                .keyboardType(.URL)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard, content: {
                        Spacer()
                        Button("Done", action: {focusedField = nil})
                    })
                }
#endif
        }
        .onReceive(engine.$outputs) {
            if model.responses != $0 {
                determineResult(for: $0)
            }
        }
    }
}

// MARK: - Form Calculation

extension LinkForm: BuilderForm {
    func determineResult(for outputs: [String]) {
        print("Result determined")
        self.model = .init(
            responses: outputs,
            result: outputs[0],
            builder: .link)
    }
    
}

struct LinkForm_Previews: PreviewProvider {
    static var previews: some View {
        LinkForm(model: .constant(BuilderModel(for: .link)))
    }
}

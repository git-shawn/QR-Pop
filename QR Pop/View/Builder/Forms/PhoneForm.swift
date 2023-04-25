//
//  PhoneForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI

struct PhoneForm: View {
    @Binding var model: BuilderModel
    
    /// TextField focus information
    private enum Field: Hashable {
        case phone
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Phone Number", text: $model.responses[0])
#if os(iOS)
                .keyboardType(.phonePad)
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
#endif
                .autocorrectionDisabled(true)
                .textFieldStyle(FormTextFieldStyle())
                .focused($focusedField, equals: .phone)
        }
        .onChange(of: model.responses, debounce: 1) { val in
            model.result = model.responses[0]
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

struct PhoneForm_Previews: PreviewProvider {
    static var previews: some View {
        PhoneForm(model: .constant(BuilderModel(for: .phone)))
    }
}

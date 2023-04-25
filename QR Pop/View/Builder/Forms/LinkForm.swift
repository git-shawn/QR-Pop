//
//  LinkForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/24/22.
//

import SwiftUI

struct LinkForm: View {
    @Binding var model: BuilderModel
    
    /// TextField focus information
    private enum Field: Hashable {
        case url
    }
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter URL", text: $model.responses[0])
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
        .onChange(of: model.responses, debounce: 1) { _ in
            model.result = model.responses[0]
        }
    }
}

struct LinkForm_Previews: PreviewProvider {
    static var previews: some View {
        LinkForm(model: .constant(BuilderModel(for: .link)))
    }
}

//
//  WhatsAppForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/5/23.
//

import SwiftUI

struct WhatsAppForm: View {
    @Binding var model: BuilderModel
    
    /// TextField focus information
    private enum Field: Hashable {
        case phone
        case message
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 20) {
                TextField("Phone Number", text: $model.responses[0])
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
                TextField("Message", text: $model.responses[1], axis: .vertical)
                    .lineLimit(6, reservesSpace: true)
                    .textFieldStyle(FormTextFieldStyle())
                    .focused($focusedField, equals: .message)
                    .submitLabel(.done)
                    .limitInputLength(value: $model.responses[1], length: 160)
                    .id(Field.message)
            }
            .onChange(of: model.responses, debounce: 1) { _ in
                determineResults()
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
                        Text("\(model.responses[1].count)/160")
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

extension WhatsAppForm {
    
    func determineResults() {
        model.result = "https://api.whatsapp.com/send?phone=\(model.responses[0])\(model.responses[1].isEmpty ? "" : "&text=\(model.responses[1])")"
    }
}

struct WhatsAppForm_Previews: PreviewProvider {
    static var previews: some View {
        WhatsAppForm(model: .constant(BuilderModel(for: .whatsapp)))
    }
}

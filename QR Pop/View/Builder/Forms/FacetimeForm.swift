//
//  FacetimeForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI

struct FacetimeForm: View {
    @Binding var model: BuilderModel
    
    /// TextField focus information
    private enum Field: Hashable {
        case phone
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: 20) {
#if os(iOS)
            Menu {
                Picker(selection: $model.responses[0], label: EmptyView(), content: {
                    Text("Video").tag("")
                    Text("Audio").tag("a")
                })
                .pickerStyle(.automatic)
            } label: {
                HStack {
                    Text(model.responses[0] == "" ? "Facetime Video" : "Facetime Audio")
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .tint(.accentColor)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.secondaryGroupedBackground)
                .cornerRadius(10)
            }
#else
            Picker(selection: $model.responses[0], content: {
                Text("Video").tag("")
                Text("Audio").tag("a")
            }, label: {
                Text("Call Style")
            })
            .labelsHidden()
            .pickerStyle(.segmented)
            .background(Color.secondaryGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
#endif
            
            TextField("Phone Number", text: $model.responses[1])
#if os(iOS)
                .keyboardType(.phonePad)
                .submitLabel(.done)
#endif
                .autocorrectionDisabled(true)
                .autocorrectionDisabled(true)
                .textFieldStyle(FormTextFieldStyle())
                .focused($focusedField, equals: .phone)
        }
        .onChange(of: model.responses, debounce: 1) { _ in
            determineResult()
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

extension FacetimeForm {
    
    func determineResult() {
        if (model.responses[0] == "") {
            model.result = "facetime-audio:\(model.responses[1])"
        } else {
            model.result = "facetime:\(model.responses[1])"
        }
    }
}

struct FacetimeForm_Previews: PreviewProvider {
    static var previews: some View {
        FacetimeForm(model: .constant(BuilderModel(for: .facetime)))
    }
}

//
//  FacetimeForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI

struct FacetimeForm: View {
    @Binding var model: BuilderModel
    @StateObject var engine: FormStateEngine
    
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case phone
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
        VStack(spacing: 20) {
#if os(iOS)
            Menu {
                Picker(selection: $engine.inputs[0], label: EmptyView(), content: {
                    Text("Video").tag("")
                    Text("Audio").tag("a")
                })
                .pickerStyle(.automatic)
            } label: {
                HStack {
                    Text(engine.inputs[0] == "" ? "Facetime Video" : "Facetime Audio")
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
            Picker(selection: $engine.inputs[0], content: {
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
            
            TextField("Phone Number", text: $engine.inputs[1])
#if os(iOS)
                .keyboardType(.phonePad)
                .submitLabel(.done)
#endif
                .autocorrectionDisabled(true)
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

extension FacetimeForm: BuilderForm {
    
    func determineResult(for outputs: [String]) {
        var result: String {
            if outputs[0].isEmpty {
                return "facetime:\(outputs[1])"
            } else {
                return "facetime-audio:\(outputs[1])"
            }
        }
        
        self.model = .init(
            responses: outputs,
            result: result,
            builder: .facetime)
    }
}

struct FacetimeForm_Previews: PreviewProvider {
    static var previews: some View {
        FacetimeForm(model: .constant(BuilderModel(for: .facetime)))
    }
}

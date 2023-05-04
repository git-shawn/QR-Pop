//
//  ShortcutsForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI

struct ShortcutForm: View {
    @Binding var model: BuilderModel
    @StateObject var engine: FormStateEngine
    
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case name
        case input
    }
    
    init(model: Binding<BuilderModel>) {
        self._model = model
        
        if model.wrappedValue.responses.isEmpty {
            self._engine = .init(wrappedValue: .init(initial: ["", "", ""]))
        } else {
            self._engine = .init(wrappedValue: .init(initial: model.wrappedValue.responses))
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 20) {
#if os(iOS)
                Menu {
                    Picker(selection: $engine.inputs[0], label: EmptyView(), content: {
                        Text("None").tag("")
                        Text("Text").tag("text")
                        Text("Pasteboard").tag("clipboard")
                    })
                    .pickerStyle(.automatic)
                } label: {
                    HStack {
                        Text(engine.inputs[0].isEmpty ? "No Input" : (engine.inputs[0] == "text" ? "Predefined Input" : "Input from Pasteboard"))
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
                HStack {
                    Text("Shortcut Input")
                    Spacer()
                    Picker(selection: $engine.inputs[0], content: {
                        Text("No Input").tag("")
                        Text("Text").tag("text")
                        Text("Pasteboard").tag("clipboard")
                    }, label: {
                        Text("Shortcut Input")
                    })
                    .buttonStyle(.borderless)
                    .labelsHidden()
                    .pickerStyle(.automatic)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
#endif
                TextField("Shortcut Name", text: $engine.inputs[1])
                    .autocorrectionDisabled(true)
                    .textFieldStyle(FormTextFieldStyle())
                    .focused($focusedField, equals: .name)
#if os(iOS)
                    .textInputAutocapitalization(.never)
                    .submitLabel(engine.inputs[0] == "text" ? .next : .done)
                    .onSubmit {
                        if (engine.inputs[0] == "text") {
                            focusedField = .input
                        }
                    }
#endif
                if (engine.inputs[0] == "text") {
                    TextField("Shortcut Input", text: $engine.inputs[2], axis: .vertical)
                        .lineLimit(6, reservesSpace: true)
                        .textFieldStyle(FormTextFieldStyle())
                        .focused($focusedField, equals: .input)
                        .submitLabel(.done)
                        .limitInputLength(value: $engine.inputs[2], length: 1000)
                        .id(Field.input)
                }
            }
            .onReceive(engine.$outputs) {
                if model.responses != $0 {
                    determineResult(for: $0)
                }
            }
#if os(iOS)
            .onChange(of: focusedField, perform: {field in
                if field == .input {
                    withAnimation {
                        proxy.scrollTo(Field.input, anchor: .center)
                    }
                }
            })
            .toolbar {
                ToolbarItemGroup(placement: .keyboard, content: {
                    Spacer()
                    Button("Done", action: {focusedField = nil})
                })
            }
#endif
        }
    }
}

// MARK: - Form Calculation

extension ShortcutForm: BuilderForm {
    func determineResult(for outputs: [String]) {
        var result: String {
            let base = "shortcuts://run-shortcut?name=\(outputs[1].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            
            switch outputs[0] {
            case "clipboard":
                return base+"&input=clipboard"
            case "text":
                return base+"&input=\(outputs[2].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            default:
                return base
            }
        }
        
        self.model = .init(
            responses: outputs,
            result: result,
            builder: .shortcut)
    }
}

struct ShortcutForm_Previews: PreviewProvider {
    static var previews: some View {
        ShortcutForm(model: .constant(BuilderModel(for: .shortcut)))
    }
}

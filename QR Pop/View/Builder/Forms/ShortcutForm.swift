//
//  ShortcutsForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI

struct ShortcutForm: View {
    @Binding var model: BuilderModel
    
    /// TextField focus information
    private enum Field: Hashable {
        case name
        case input
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 20) {
#if os(iOS)
                Menu {
                    Picker(selection: $model.responses[0], label: EmptyView(), content: {
                        Text("None").tag("")
                        Text("Text").tag("text")
                        Text("Pasteboard]").tag("clipboard")
                    })
                    .pickerStyle(.automatic)
                } label: {
                    HStack {
                        Text(model.responses[0] == "" ? "No Input" : (model.responses[0] == "text" ? "Predefined Input" : "Input from Pasteboard"))
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
                    Picker(selection: $model.responses[0], content: {
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
                TextField("Shortcut Name", text: $model.responses[1])
                    .autocorrectionDisabled(true)
                    .textFieldStyle(FormTextFieldStyle())
                    .focused($focusedField, equals: .name)
#if os(iOS)
                    .textInputAutocapitalization(.never)
                    .submitLabel(model.responses[0] == "text" ? .next : .done)
                    .onSubmit {
                        if (model.responses[0] == "text") {
                            focusedField = .input
                        }
                    }
#endif
                if (model.responses[0] == "text") {
                    TextField("Shortcut Input", text: $model.responses[2], axis: .vertical)
                        .lineLimit(6, reservesSpace: true)
                        .textFieldStyle(FormTextFieldStyle())
                        .focused($focusedField, equals: .input)
                        .submitLabel(.done)
                        .limitInputLength(value: $model.responses[2], length: 1000)
                        .id(Field.input)
                }
            }
            .onChange(of: model.responses, debounce: 1) { _ in
                determineResult()
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

extension ShortcutForm {
    
    func determineResult() {
        let formattedName = model.responses[1].replacingOccurrences(of: " ", with: "%20")
        
        if (model.responses[0].isEmpty) {
            model.result = "shortcuts://run-shortcut?name=\(formattedName)"
        } else if (model.responses[0] == "clipboard") {
            model.result = "shortcuts://run-shortcut?name=\(formattedName)&input=clipboard"
        } else {
            model.result = "shortcuts://run-shortcut?name=\(formattedName)&input=\(model.responses[2])"
        }
    }
}

struct ShortcutForm_Previews: PreviewProvider {
    static var previews: some View {
        ShortcutForm(model: .constant(BuilderModel(for: .shortcut)))
    }
}

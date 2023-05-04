//
//  TextForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI

struct TextForm: View {
    @Binding var model: BuilderModel
    @StateObject var engine: FormStateEngine
    @State private var writeFullScreen: Bool = false
    
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case text
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
        ScrollViewReader { proxy in
            VStack(spacing: 20) {
                TextField("Message", text: $engine.inputs[0], axis: .vertical)
                    .lineLimit(8, reservesSpace: true)
                    .textFieldStyle(FormTextFieldStyle())
                    .focused($focusedField, equals: .text)
                    .limitInputLength(value: $engine.inputs[0], length: 1500)
                    .submitLabel(.return)
                    .textEditor("Plain Text", text: $engine.inputs[0], isPresented: $writeFullScreen)
                    .id(Field.text)
            }
            .onReceive(engine.$outputs) {
                if model.responses != $0 {
                    determineResult(for: $0)
                }
            }
#if os(iOS)
            .onChange(of: focusedField) { field in
                if field == .text {
                    withAnimation {
                        proxy.scrollTo(Field.text, anchor: .center)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard, content: {
                    if focusedField == .text {
                        Button(action: {
                            writeFullScreen.toggle()
                        }, label: {
                            Label("Make Textfield Fullscreen", systemImage: "arrow.up.backward.and.arrow.down.forward.circle")
                        })
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

extension TextForm: BuilderForm {
    func determineResult(for outputs: [String]) {
        self.model = .init(
            responses: outputs,
            result: outputs[0],
            builder: .text)
    }
}

struct TextForm_Previews: PreviewProvider {
    static var previews: some View {
        TextForm(model: .constant(BuilderModel(for: .text)))
    }
}

//
//  TwitterForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI

struct TwitterForm: View {
    @Binding var model: BuilderModel
    @StateObject var engine: FormStateEngine
    
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case account
        case tweet
    }
    
    init(model: Binding<BuilderModel>) {
        self._model = model
        
        if model.wrappedValue.responses.isEmpty {
            self._engine = .init(wrappedValue: .init(initial: ["","",""]))
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
                        Text("Follow").tag("")
                        Text("Tweet").tag("t")
                    })
                    .pickerStyle(.automatic)
                } label: {
                    HStack {
                        Text(engine.inputs[0] == "" ? "Follow Account" : "Post Tweet")
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
                    Text("Follow").tag("")
                    Text("Tweet").tag("t")
                }, label: {
                    Text("Action")
                })
                .labelsHidden()
                .pickerStyle(.segmented)
                .background(Color.secondaryGroupedBackground)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
#endif
                
                if(engine.inputs[0].isEmpty) {
                    TextField("Account Name", text: $engine.inputs[1])
                        .autocorrectionDisabled(true)
                        .textFieldStyle(FormTextFieldStyle())
                        .focused($focusedField, equals: .account)
#if os(iOS)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .keyboardType(.twitter)
#endif
                } else {
                    TextField("Tweet", text: $engine.inputs[1], axis: .vertical)
                        .lineLimit(6, reservesSpace: true)
                        .textFieldStyle(FormTextFieldStyle())
                        .focused($focusedField, equals: .tweet)
                        .submitLabel(.return)
#if os(iOS)
                        .keyboardType(.twitter)
#endif
                        .limitInputLength(value: $engine.inputs[1], length: 280)
                        .id(Field.tweet)
                }
            }
            .onReceive(engine.$outputs) {
                if model.responses != $0 {
                    determineResult(for: $0)
                }
            }
#if os(iOS)
            .onChange(of: focusedField) { field in
                if field == .tweet {
                    withAnimation {
                        proxy.scrollTo(Field.tweet, anchor: .center)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard, content: {
                    if focusedField == .tweet {
                        Spacer()
                        Text("\(engine.inputs[1].count)/280")
                    }
                    Spacer()
                    Button("Done", action: {focusedField = nil})
                })
            }
#endif
        }
    }
}

//MARK: - Form Calculation

extension TwitterForm: BuilderForm {
    func determineResult(for outputs: [String]) {
        var result: String {
            if outputs[0].isEmpty {
                return "https://twitter.com/intent/user?screen_name=\(outputs[1])"
            } else {
                return "https://twitter.com/intent/tweet?text=\(outputs[2].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            }
        }
        
        self.model = .init(
            responses: outputs,
            result: result,
            builder: .twitter)
    }
}

struct TwitterForm_Previews: PreviewProvider {
    static var previews: some View {
        TwitterForm(model: .constant(BuilderModel(for: .twitter)))
    }
}

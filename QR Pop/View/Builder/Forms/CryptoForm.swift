//
//  BitcoinForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI

struct CryptoForm: View {
    @Binding var model: BuilderModel
    @StateObject var engine: FormStateEngine
    
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case address
        case amount
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
        VStack(spacing: 20) {
#if os(iOS)
            Menu {
                Picker(selection: $engine.inputs[0], label: EmptyView(), content: {
                    Text("Bitcoin").tag("")
                    Text("Ethereum").tag("ethereum")
                    Text("Bitcoin Cash").tag("bitcoincash")
                    Text("Litecoin").tag("litecoin")
                })
                .pickerStyle(.automatic)
            } label: {
                HStack {
                    switch engine.inputs[0] {
                    case "ethereum":
                        Text("Ethereum")
                    case "bitcoincash":
                        Text("Bitcoin Cash")
                    case "litecoin":
                        Text("Litecoin")
                    default:
                        Text("Bitcoin")
                    }
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
                Text("Currency")
                Spacer()
                Picker(selection: $engine.inputs[0], content: {
                    Text("Bitcoin").tag("")
                    Text("Ethereum").tag("ethereum")
                    Text("Bitcoin Cash").tag("bitcoincash")
                    Text("Litecoin").tag("litecoin")
                }, label: {
                    Text("Currency")
                })
                .buttonStyle(.borderless)
                .labelsHidden()
                .pickerStyle(.automatic)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
#endif
            
            TextField("Public Wallet Address", text: $engine.inputs[1])
                .textFieldStyle(FormTextFieldStyle())
                .focused($focusedField, equals: .address)
                .autocorrectionDisabled(true)
#if os(iOS)
                .textInputAutocapitalization(.never)
                .submitLabel(.next)
                .keyboardType(.twitter)
                .onSubmit {
                    focusedField = .amount
                }
#endif
            
            TextField("Amount", text: $engine.inputs[2])
                .textFieldStyle(FormTextFieldStyle())
                .focused($focusedField, equals: .amount)
                .submitLabel(.done)
#if os(iOS)
                .keyboardType(.decimalPad)
#endif
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

extension CryptoForm: BuilderForm {
    
    func determineResult(for outputs: [String]) {
        var result: String {
            let scheme = "\(outputs[0].isEmpty ? "bitcoin" : outputs[0])"
            let query = "\(outputs[2].isEmpty ? "" : "?amount\\"+outputs[2] )"
            return scheme+outputs[1]+query
        }
        
        self.model = .init(
            responses: outputs,
            result: result,
            builder: .crypto)
    }
}

struct CryptoForm_Previews: PreviewProvider {
    static var previews: some View {
        CryptoForm(model: .constant(BuilderModel(for: .crypto)))
    }
}

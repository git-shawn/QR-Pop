//
//  BitcoinForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI

struct CryptoForm: View {
    @Binding var model: BuilderModel
    
    private enum Field: Hashable {
        case address
        case amount
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: 20) {
#if os(iOS)
            Menu {
                Picker(selection: $model.responses[0], label: EmptyView(), content: {
                    Text("Bitcoin").tag("")
                    Text("Ethereum").tag("ethereum")
                    Text("Bitcoin Cash").tag("bitcoincash")
                    Text("Litecoin").tag("litecoin")
                })
                .pickerStyle(.automatic)
            } label: {
                HStack {
                    switch model.responses[0] {
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
                Picker(selection: $model.responses[0], content: {
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
            
            TextField("Public Wallet Address", text: $model.responses[1])
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
            
            TextField("Amount", text: $model.responses[2])
                .textFieldStyle(FormTextFieldStyle())
                .focused($focusedField, equals: .amount)
                .submitLabel(.done)
#if os(iOS)
                .keyboardType(.decimalPad)
#endif
        }
        .onChange(of: model.responses, debounce: 1) {_ in
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

extension CryptoForm {
    
    func determineResult() {
        model.result = "\(model.responses[0].isEmpty ? "bitcoin" : model.responses[0]):\(model.responses[1])\(model.responses[2].isEmpty ? "" : "?amount\(model.responses[2])")"
    }
}

struct CryptoForm_Previews: PreviewProvider {
    static var previews: some View {
        CryptoForm(model: .constant(BuilderModel(for: .crypto)))
    }
}

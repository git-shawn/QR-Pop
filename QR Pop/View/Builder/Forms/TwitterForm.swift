//
//  TwitterForm.swift
//  QR Pop
//
//  Created by Shawn Davis on 9/25/22.
//

import SwiftUI

struct TwitterForm: View {
    @Binding var model: BuilderModel
    
    /// TextField focus information
    private enum Field: Hashable {
        case account
        case tweet
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 20) {
#if os(iOS)
                Menu {
                    Picker(selection: $model.responses[0], label: EmptyView(), content: {
                        Text("Follow").tag("")
                        Text("Tweet").tag("t")
                    })
                    .pickerStyle(.automatic)
                } label: {
                    HStack {
                        Text(model.responses[0] == "" ? "Follow Account" : "Post Tweet")
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
                
                if(model.responses[0].isEmpty) {
                    TextField("Account Name", text: $model.responses[1])
                        .autocorrectionDisabled(true)
                        .textFieldStyle(FormTextFieldStyle())
                        .focused($focusedField, equals: .account)
#if os(iOS)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .keyboardType(.twitter)
#endif
                } else {
                    TextField("Tweet", text: $model.responses[1], axis: .vertical)
                        .lineLimit(6, reservesSpace: true)
                        .textFieldStyle(FormTextFieldStyle())
                        .focused($focusedField, equals: .tweet)
                        .submitLabel(.return)
#if os(iOS)
                        .keyboardType(.twitter)
#endif
                        .limitInputLength(value: $model.responses[1], length: 280)
                        .id(Field.tweet)
                }
            }
            // Reset the TextField when the type of Twitter URL changes
            .onChange(of: model.responses[0]) { _ in
                model.responses[1] = ""
            }
            .onChange(of: model.responses, debounce: 1) { _ in
                determineResult()
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
                        Text("\(model.responses[1].count)/280")
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

extension TwitterForm {
    
    func determineResult() {
        if model.responses[0].isEmpty {
            model.responses[1] = model.responses[1].replacingOccurrences(of: "@", with: "")
            model.result = "https://twitter.com/intent/user?screen_name=\(model.responses[1])"
        } else {
            let sanitizedTweet = model.responses[2].replacingOccurrences(of: " ", with: "%20")
            model.result = "https://twitter.com/intent/tweet?text=\(sanitizedTweet)"
        }
    }
}

struct TwitterForm_Previews: PreviewProvider {
    static var previews: some View {
        TwitterForm(model: .constant(BuilderModel(for: .twitter)))
    }
}

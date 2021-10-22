//
//  TextEditorModal.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/21/21.
//

import SwiftUI

struct TextEditorModal: View {
    @State var showTextEditor: Bool = false
    @Binding var text: String

    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack() {
            Button(action: {
                self.showTextEditor = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.isFocused = true
                }
            }) {
                VStack {
                Text((text != "" ? text : "Enter some text..."))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(text != "" ? .primary : Color(UIColor.placeholderText))
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 5)
                Divider()
                .padding(.leading)
                .padding(.bottom)
                }
            }
        }.sheet(isPresented: $showTextEditor) {
            VStack(alignment: .leading) {
                Group {
                    HStack {
                        Button(action: {
                            self.text = ""
                        }) {
                            Text("Clear")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .foregroundColor(Color(UIColor.systemFill))
                            )
                        }
                        Spacer()
                        Text("\(text.count)/2000")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor((text.count < 2000) ? Color(UIColor.secondaryLabel) : .red)
                        Spacer()
                        Button(action: {
                            showTextEditor = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color(UIColor.secondaryLabel), Color(UIColor.systemFill))
                                .font(.title)
                                .accessibility(label: Text("Close"))
                        }
                    }
                    TextView(text: $text, isFirstResponder: true)
                        .keyboardType(UIKeyboardType.asciiCapable)
                }.padding()
            }
        }
    }
}

struct TextView: UIViewRepresentable {
    @Binding var text: String
    var isFirstResponder: Bool = false
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        var didBecomeFirstResponder = false

        init(text: Binding<String>) {
            _text = text
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            text = textView.text ?? ""
        }
    }

    func makeUIView(context: UIViewRepresentableContext<TextView>) -> UITextView {
        let textView = UITextView(frame: .zero)
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<TextView>) {
        if (text.count < 2000) {
            uiView.text = text
        } else {
            uiView.text = String(text.prefix(2000))
        }
        uiView.font = .systemFont(ofSize: 18)
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}

struct TextEditorModal_Previews: PreviewProvider {
    @State static var text = ""
    static var previews: some View {
        TextEditorModal(text: $text)
    }
}

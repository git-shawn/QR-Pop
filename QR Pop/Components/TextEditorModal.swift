//
//  TextEditorModal.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/21/21.
//
import SwiftUI

/// A modal view that allows the user to enter text to be entered into a QR code.
/// Maximum of 2000 characters.
struct TextEditorModal: View {
    @Binding var showTextEditor: Bool
    @Binding var text: String

    @FocusState private var isFocused: Bool
    #if os(macOS)
    private let gradient = LinearGradient(
        gradient: Gradient(colors: [Color.black, .white]),
        startPoint: .top,
        endPoint: .bottom
    )
    #endif
    
    var body: some View {
        VStack() {
            Button(action: {
                self.showTextEditor = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.isFocused = true
                }
            }) {
                VStack {
                    Text((text != "" ? text : "Enter Some Text..."))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(text != "" ? .primary : Color("PlaceholderText"))
                    .multilineTextAlignment(.leading)
                    #if os(macOS)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .background(.ultraThickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 1)
                            .fill(gradient)
                            .opacity(0.1)
                    )
                    .padding(10)
                    #else
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 5)
                    #endif
                    
                    #if os(iOS)
                    Divider()
                    .padding(.leading)
                    #endif
                }
            }
            #if os(macOS)
            .buttonStyle(.plain)
            #endif
        }.sheet(isPresented: $showTextEditor) {
            VStack(alignment: .leading) {
                Group {
                    HStack {
                        Button(action: {
                            self.text = ""
                        }) {
                            Text("Clear")
                            .font(.headline)
                            .foregroundColor(Color("secondaryLabel"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .foregroundColor(Color("SystemFill"))
                            )
                        }
                        #if os(macOS)
                        .buttonStyle(.plain)
                        #endif
                        Spacer()
                        #if os(macOS)
                        Button(action: {
                            NSApp.orderFrontCharacterPalette(nil)
                        }) {
                            Image(systemName: "face.smiling.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color("secondaryLabel"), Color("SystemFill"))
                                .font(.title)
                                .accessibility(label: Text("Emojis & Symbols"))
                        }.buttonStyle(.plain)
                        .padding(.trailing, 10)
                        #endif
                        Button(action: {
                            showTextEditor = false
                        }) {
                            if (text.isEmpty) {
                                Image(systemName: "xmark.circle.fill")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(Color("secondaryLabel"), Color("SystemFill"))
                                    .font(.title)
                                    .accessibility(label: Text("Close"))
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(Color("secondaryLabel"), Color("SystemFill"))
                                    .font(.title)
                                    .accessibility(label: Text("Done"))
                            }
                        }
                        #if os(macOS)
                        .keyboardShortcut(.cancelAction)
                        .buttonStyle(.plain)
                        #endif
                    }.overlay(
                        Text("\(text.count)/2000")
                        .font(.headline)
                        .foregroundColor((text.count < 2000) ? Color("secondaryLabel") : .red)
                    )
                    TextView(text: $text, isFirstResponder: true)
                    #if os(iOS)
                        .keyboardType(UIKeyboardType.asciiCapable)
                    #endif
                }.padding()
            }
            #if os(macOS)
            .frame(width: 500, height: 500)
            .background(Color(NSColor.textBackgroundColor))
            #endif
        }
    }
}

#if os(iOS)
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
#else

struct TextView: View {
    @Binding var text: String
    var isFirstResponder: Bool = false
    
    var body: some View {
        TextEditor(text: $text)
            .background(.clear)
    }
}

#endif

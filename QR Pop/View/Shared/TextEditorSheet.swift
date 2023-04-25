//
//  TextEditorSheet.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI

struct TextEditorModal: View {
    @Binding var isPresented: Bool
    @Binding var text: String
    var title: String
    @FocusState private var focused: Bool
    
    var body: some View {
        NavigationStack {
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .padding()
                .focused($focused)
                .navigationTitle(title)
#if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
                .toolbar {
                    ToolbarItem(placement: .confirmationAction, content: {
                        Button("Done", action: {
                            isPresented = false
                        })
                        .keyboardShortcut(.cancelAction)
                    })
                    ToolbarItemGroup(placement: .keyboard, content: {
                        Button(action: {
                            isPresented = false
                        }, label: {
                            Label("Minimize Textfield", systemImage: "arrow.down.forward.and.arrow.up.backward.circle")
                        })
                        Spacer()
                    })
                }
        }
        .onAppear {
            focused = true
        }
    }
}

struct TextEditorModal_Previews: PreviewProvider {
    static var previews: some View {
        TextEditorModal(isPresented: .constant(true), text: .constant("Hello"), title: "uh oh")
    }
}

extension View {
    public func textEditor(_ title: String = "", text: Binding<String>, isPresented: Binding<Bool>) -> some View {
        self.sheet(isPresented: isPresented, content: {
            TextEditorModal(isPresented: isPresented, text: text, title: title)
#if os(macOS)
                .frame(minWidth: 400, maxWidth: 600, minHeight: 400, maxHeight: 600)
#endif
        })
    }
}

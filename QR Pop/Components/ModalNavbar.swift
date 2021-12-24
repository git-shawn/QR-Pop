//
//  ModalNavbar.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 11/8/21.
//

import SwiftUI

/// Navigation buttons for modal views such as a title and close button.
struct ModalNavbar<Content: View>: View {
    let content: Content
    let navigationTitle: String
    @Binding var showModal: Bool

    init(navigationTitle: String = "QR Pop", showModal: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.navigationTitle = navigationTitle
        self._showModal = showModal
    }
    var body: some View {
        #if os(iOS)
        NavigationView {
            VStack {
                content
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        showModal.toggle()
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color("secondaryLabel"), Color("SystemFill"))
                        .opacity(1)
                        .font(.title2)
                        .accessibility(label: Text("Close"))
                    })
                }
            }
        }
        #else
        ZStack(alignment: .topTrailing) {
            content
            
            Button(action: {
                showModal.toggle()
            }, label: {
                Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color("secondaryLabel"), Color("SystemFill"))
                .opacity(1)
                .font(.title)
                .accessibility(label: Text("Close"))
            })
            .keyboardShortcut(.cancelAction)
            .buttonStyle(.plain)
            .padding()
        }.frame(width: 500, height: 550)
        #endif
    }
}

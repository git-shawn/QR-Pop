//
//  SEPermissionModal.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/17/21.
//
import SwiftUI

/// A modal view to explain wifi terminology
struct SEPermissionModal: View {
    @Binding var isPresented: Bool
    var body: some View {
        ModalNavbar(navigationTitle: "Permissions", showModal: $isPresented) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Why should I allow all websites?")
                            .font(.largeTitle)
                            .bold()
                    Text("QR Pop works by extracting the URL from a webpage and converting it into a QR code. Allowing \"All Websites\" makes this process convenient and automatic.\n\nGiving an extension the ability to see every URL you visit can be risky business, so Safari checks to make sure you're serious before sharing that information.\n\nYou can be confident knowing no funny business is going on. QR Pop's privacy policy explicitly states that all codes are created on-device and that this app contains no loggers, trackers, etc.\n\nHowever, for those more technical, you don't need to take my word for it. Feel free to browse the source code and see for yourself.")
                }.padding()
            }
        }
    }
}

struct SEPermissionModal_Previews: PreviewProvider {
    @State static var show: Bool = true
    static var previews: some View {
        SEPermissionModal(isPresented: $show)
    }
}

//
//  ShareButtono.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

/// A button that calls either the Share Sheet or Share Picker, depending on platform.
struct ShareButton: View {
    var shareContent: [Any]
    var buttonTitle: String
    var hideIcon: Bool = false
    #if os(macOS)
    @State private var showPicker = false
    #endif
    
    var body: some View {
        Button(action: {
            #if os(iOS)
            showShareSheet(with: shareContent, formatImageToPrint: true)
            #else
            showPicker = true
            #endif
        }) {
            if(hideIcon) {
                Text(buttonTitle)
            } else {
                Label(buttonTitle, systemImage: "square.and.arrow.up")
            }
        }
        #if os(macOS)
        .background(SharingsPicker(isPresented: $showPicker, sharingItems: shareContent))
        #endif
    }
}

struct ShareButton_Previews: PreviewProvider {
    @State static var showShare = true
    static var previews: some View {
        ShareButton(shareContent: [URL(string: "www.google.com")!], buttonTitle: "Share Me!")
    }
}

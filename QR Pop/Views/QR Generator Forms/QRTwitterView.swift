//
//  QRTwitterView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRTwitterView: View {
    @EnvironmentObject var qrCode: QRCode
    
    @State private var showTextModal: Bool = false
    
    private func setCodeContent() {
        if qrCode.formStates[0].isEmpty {
            qrCode.formStates[1] = qrCode.formStates[1].replacingOccurrences(of: "@", with: "")
            let fullURL = "https://twitter.com/intent/user?screen_name=\(qrCode.formStates[1])"
            qrCode.setContent(string: fullURL)
        } else {
            let sanitizedTweet = qrCode.formStates[2].replacingOccurrences(of: " ", with: "%20")
            let fullURL = "https://twitter.com/intent/tweet?text=\(sanitizedTweet)"
            qrCode.setContent(string: fullURL)
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Picker("Twitter URL Type", selection: $qrCode.formStates[0]) {
                Text("Follow").tag("")
                Text("Tweet").tag("t")
            }
                .pickerStyle(.segmented)
                .padding(.horizontal)
            
            if (qrCode.formStates[0].isEmpty) {
                Group {
                    TextField("Enter Account Name", text: $qrCode.formStates[1])
                        .textFieldStyle(QRPopTextStyle())
                    #if os(iOS)
                        .keyboardType(.default)
                        .submitLabel(.done)
                        .autocapitalization(.none)
                    #endif
                        .disableAutocorrection(true)
                        .onChange(of: qrCode.formStates) {_ in
                            setCodeContent()
                        }
                }.animation(.spring(), value: qrCode.formStates[1])
            } else {
                TextEditorModal(showTextEditor: $showTextModal, text: $qrCode.formStates[2])
                    .onChange(of: showTextModal) {_ in
                        setCodeContent()
                    }
                    .animation(.spring(), value: qrCode.formStates)
            }
        }
    }
}

struct QRTwitterView_Previews: PreviewProvider {
    static var previews: some View {
        QRTwitterView()
    }
}

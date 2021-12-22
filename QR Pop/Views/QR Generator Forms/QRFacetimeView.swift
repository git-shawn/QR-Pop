//
//  QRFacetimeView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRFacetimeView: View {
    @EnvironmentObject var qrCode: QRCode

    @State private var text: String = ""
    @State private var isFacetimeAudio: Bool = false

    private func setCodeContent() {
        if (isFacetimeAudio) {
            qrCode.setContent(string: "facetime-audio:"+text)
        } else {
            qrCode.setContent(string: "facetime:"+text)
        }
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Picker("FaceTime Video or Audio", selection: $isFacetimeAudio) {
                Text("Video").tag(false)
                Text("Audio").tag(true)
            }
                .padding()
                .pickerStyle(.segmented)
                .onChange(of: isFacetimeAudio) {_ in
                    setCodeContent()
                }
            
            TextField("Enter Phone Number or Email", text: $text)
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.namePhonePad)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onChange(of: text) {_ in
                    setCodeContent()
                }
        }.onChange(of: qrCode.codeContent, perform: {value in
            if (value.isEmpty) {
                text = ""
                isFacetimeAudio = false
            }
        })
    }
}

struct QRFacetimeView_Previews: PreviewProvider {
    static var previews: some View {
        QRFacetimeView()
    }
}

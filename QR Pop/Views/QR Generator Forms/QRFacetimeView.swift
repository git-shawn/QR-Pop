//
//  QRFacetimeView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRFacetimeView: View {
    @EnvironmentObject var qrCode: QRCode

    private func setCodeContent() {
        if (qrCode.formStates[0] == "") {
            qrCode.setContent(string: "facetime-audio:"+qrCode.formStates[1])
        } else {
            qrCode.setContent(string: "facetime:"+qrCode.formStates[1])
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Picker("FaceTime Video or Audio", selection: $qrCode.formStates[0]) {
                Text("Video").tag("")
                Text("Audio").tag("a")
            }
                .padding(.horizontal)
                .pickerStyle(.segmented)
            
            TextField("Enter Phone Number or Email", text: $qrCode.formStates[1])
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .keyboardType(.namePhonePad)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
            
        }.onChange(of: qrCode.formStates, perform: {_ in
            setCodeContent()
        })
    }
}

struct QRFacetimeView_Previews: PreviewProvider {
    static var previews: some View {
        QRFacetimeView()
    }
}

//
//  QRShortcutView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRShortcutView: View {
    @EnvironmentObject var qrCode: QRCode
    
    func setCodeContent() {
        var codeString: String = ""
        let formattedName = qrCode.formStates[1].replacingOccurrences(of: " ", with: "%20")
        
        if (qrCode.formStates[0].isEmpty) {
            codeString = "shortcuts://run-shortcut?name=\(formattedName)"
        } else if (qrCode.formStates[0] == "clipboard") {
            codeString = "shortcuts://run-shortcut?name=\(formattedName)&input=clipboard"
        } else {
            codeString = "shortcuts://run-shortcut?name=\(formattedName)&input=\(qrCode.formStates[2])"
        }
        qrCode.setContent(string: codeString)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack {
                #if os(iOS)
                Text("Shortcut Input")
                Spacer()
                #endif
                Picker("Shortcut Input", selection: $qrCode.formStates[0].animation(.easeIn)) {
                    Text("None").tag("")
                    Text("Text").tag("text")
                    Text("Clipboard").tag("clipboard")
                }.help("The type of input the Shortcut accepts, if any.")
                #if os(iOS)
                .pickerStyle(.menu)
                .padding(.vertical, 5)
                .padding(.horizontal, 15)
                .background(Color("ButtonBkg"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                #endif
            }.padding(.horizontal, 15)
            
            TextField("Enter Shortcut Name", text: $qrCode.formStates[1])
                .textFieldStyle(QRPopTextStyle())
                .help("The name of the Shortcut, exactly as it appears in the app.")
            #if os(iOS)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
            
            if (qrCode.formStates[0] == "text") {
                TextField("Enter Input Text", text: $qrCode.formStates[2])
                    .textFieldStyle(QRPopTextStyle())
                    .help("The input to pass to the Shortcut when it runs.")
                #if os(iOS)
                    .autocapitalization(.none)
                    .submitLabel(.done)
                #endif
                    .disableAutocorrection(true)
            }
        }.onChange(of: qrCode.formStates, perform: {_ in
            setCodeContent()
        })
    }
}

struct QRShortcutView_Previews: PreviewProvider {
    static var previews: some View {
        QRShortcutView()
    }
}

//
//  QRShortcutView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRShortcutView: View {
    @EnvironmentObject var qrCode: QRCode

    @State private var name: String = ""
    @State private var input: String = ""
    @State private var inputString: String = ""
    
    func setCodeContent() {
        var codeString: String = ""
        let formattedName = name.replacingOccurrences(of: " ", with: "%20")
        
        if (input.isEmpty) {
            codeString = "shortcuts://run-shortcut?name=\(formattedName)"
        } else if (input == "clipboard") {
            codeString = "shortcuts://run-shortcut?name=\(formattedName)&input=clipboard"
        } else {
            codeString = "shortcuts://run-shortcut?name=\(formattedName)&input=\(inputString)"
        }
        qrCode.setContent(string: codeString)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                #if os(iOS)
                Text("Shortcut Input")
                Spacer()
                #endif
                Picker("Shortcut Input", selection: $input.animation(.easeIn)) {
                    Text("None").tag("")
                    Text("Text").tag("text")
                    Text("Clipboard").tag("clipboard")
                }.help("The type of input the Shortcut accepts, if any.")
                #if os(iOS)
                .pickerStyle(.menu)
                .padding(.vertical, 5)
                .padding(.horizontal, 15)
                .background(.ultraThickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                #endif
                .onChange(of: input) { value in
                    setCodeContent()
                }
            }.padding(15)
            
            TextField("Enter Shortcut Name", text: $name)
                .textFieldStyle(QRPopTextStyle())
                .help("The name of the Shortcut, exactly as it appears in the app.")
            #if os(iOS)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onChange(of: name) { value in
                    setCodeContent()
                }
            
            if (input == "text") {
                TextField("Enter Input Text", text: $inputString)
                    .textFieldStyle(QRPopTextStyle())
                    .help("The input to pass to the Shortcut when it runs.")
                #if os(iOS)
                    .autocapitalization(.none)
                    .submitLabel(.done)
                #endif
                    .disableAutocorrection(true)
                    .onChange(of: inputString) { value in
                        setCodeContent()
                    }
            }
        }.onChange(of: qrCode.codeContent, perform: {value in
            if (value.isEmpty) {
                name = ""
                input = ""
                inputString = ""
            }
        })
    }
}

struct QRShortcutView_Previews: PreviewProvider {
    static var previews: some View {
        QRShortcutView()
    }
}

//
//  QRShortcutView.swift
//  QR Pop
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct QRShortcutView: View {
    @State private var qrData: Data
    @State private var bgColor: Color = .white
    @State private var fgColor: Color = .black
    private let qrCode = QRCode()
    #if os(macOS)
    @State private var showDesignPopover: Bool = false
    #endif
    
    //Unique variables for shortcuts
    @State private var name: String = ""
    @State private var input: String = ""
    @State private var inputString: String = ""
    @State private var showHelp: Bool = false
    
    init() {
        qrData = qrCode.generate(content: "shortcuts://run-shortcut?name=", fg: .black, bg: .white, encoding: .utf8)
    }
    
    func constructCode() {
        var codeString: String = ""
        let formattedName = name.replacingOccurrences(of: " ", with: "%20")
        
        if (input.isEmpty) {
            codeString = "shortcuts://run-shortcut?name=\(formattedName)"
        } else if (input == "clipboard") {
            codeString = "shortcuts://run-shortcut?name=\(formattedName)&input=clipboard"
        } else {
            codeString = "shortcuts://run-shortcut?name=\(formattedName)&input=\(inputString)"
        }
        qrData = qrCode.generate(content: codeString, fg: fgColor, bg: bgColor, encoding: .utf8)
    }
    
    var body: some View {
        ScrollView {
            QRImage(qrCode: $qrData, bg: $bgColor, fg: $fgColor)
                .padding()
            
            HStack {
                #if os(iOS)
                Text("Shortcut Input")
                Spacer()
                #endif
                Picker("Shortcut Input", selection: $input.animation(.spring())) {
                    Text("None").tag("")
                    Text("Text").tag("text")
                    Text("Clipboard").tag("clipboard")
                }
                #if os(iOS)
                .pickerStyle(.menu)
                .padding(.vertical, 5)
                .padding(.horizontal, 15)
                .background(.ultraThickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                #endif
                .onChange(of: input) { value in
                    constructCode()
                }
            }.padding(20)
            
            TextField("Enter Shortcut Name", text: $name)
                .textFieldStyle(QRPopTextStyle())
            #if os(iOS)
                .autocapitalization(.none)
                .submitLabel(.done)
            #endif
                .disableAutocorrection(true)
                .onChange(of: name) { value in
                    constructCode()
                }
            
            if (input == "text") {
                TextField("Enter Input Text", text: $inputString)
                    .textFieldStyle(QRPopTextStyle())
                #if os(iOS)
                    .autocapitalization(.none)
                    .submitLabel(.done)
                #endif
                    .disableAutocorrection(true)
                    .onChange(of: inputString) { value in
                        constructCode()
                    }
            }
            
            #if os(iOS)
            QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
            .onChange(of: [bgColor, fgColor]) { value in
                constructCode()
            }
            #endif
        }.navigationTitle("Shortcut Generator")
        .toolbar(content: {
            HStack{
                Button(
                action: {
                    showHelp.toggle()
                }) {
                    Label("Help", systemImage: "questionmark.circle")
                        .labelStyle(.iconOnly)
                }
                #if os(macOS)
                Button(
                action: {
                    showDesignPopover.toggle()
                }){
                    Image(systemName: "paintpalette")
                }
                .popover(isPresented: $showDesignPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                    QRCodeDesigner(bgColor: $bgColor, fgColor: $fgColor)
                    .onChange(of: [bgColor, fgColor]) { value in
                        constructCode()
                    }.frame(minWidth: 300)
                }
                #endif
                Button(
                action: {
                    name = ""
                    input = ""
                    inputString = ""
                    fgColor = .black
                    bgColor = .white
                    constructCode()
                }){
                    Image(systemName: "trash")
                }
                #if os(macOS)
                SaveButton(qrCode: qrData)
                #endif
                ShareButton(shareContent: [qrData.image], buttonTitle: "Share")
            }
        })
        .sheet(isPresented: $showHelp) {
            shortcutHelpModal(isPresented: $showHelp)
        }
    }
}

private struct shortcutHelpModal: View {
    @Binding var isPresented: Bool
    var body: some View {
        ModalNavbar(navigationTitle: "Shortcut Help", showModal: $isPresented) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Shortcut QR Codes")
                            .font(.largeTitle)
                            .bold()
                    Group {
                        Text("What is a shortcut QR code?")
                            .font(.headline)
                        Text("Shortcut QR codes activate a Shortcut when scanned, so long as the shortcut is saved on your device already.")
                        Text("What do I enter for Shortcut Name?")
                            .font(.headline)
                        Text("Enter the name of the shortcut, exactly as it appears on your device. Include all emojis, spaces, and capitalizations the name may include.")
                        Text("What is an input type?")
                            .font(.headline)
                        Text("Some shortcuts may require an input to get started. QR Pop can pass codes with text for input, or can request that your device use text in the clipboard instead. If your device doesn't require a text input, just select *none*.")
                        Text("Why would I want this?")
                            .font(.headline)
                        Text("The fun thing about the Shortcuts app is that the possibilities are endless. You could make a shortcut to play your workout playlist, then tape the QR code to your equipment.")
                    }
                }.padding()
            }
        }
    }
}

struct QRShortcutView_Previews: PreviewProvider {
    static var previews: some View {
        QRShortcutView()
    }
}

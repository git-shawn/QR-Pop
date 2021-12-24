//
//  Acknowledgements.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 11/10/21.
//

import SwiftUI

struct Acknowledgements: View {
    var body: some View {
        ScrollView() {
            VStack(alignment: .leading, spacing: 10) {
                Group {
                    Text("Acknowledgements")
                        .font(.largeTitle)
                        .bold()
                    Text("Portions of this software may utilize the following copyrighted materials. Their contribution, and amazing work, is endlessly appreciated.")
                    Divider()
                        .padding(.vertical)
                }
                
                Text("Preferences")
                    .font(.headline)
                MITLicense()
                Divider()
                
                Text("qrcodejs")
                    .font(.headline)
                MITLicense()
                Divider()
                
                Group {
                    Text("AlertToast")
                        .font(.headline)
                    MITLicense()
                    Divider()
                    
                    Text("EFQRCode")
                        .font(.headline)
                    MITLicense()
                    Divider()
                }
            }.padding()
        }.frame(width: 450, height: 500)
    }
}

/// The MIT License as SwiftUI Text.
private struct MITLicense: View {
    var body: some View {
        Text("MIT License\n\nCopyright (c) 2021\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: \nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.")
    }
}

struct Acknowledgements_Previews: PreviewProvider {
    static var previews: some View {
        Acknowledgements()
    }
}

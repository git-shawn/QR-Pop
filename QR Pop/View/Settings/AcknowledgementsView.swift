//
//  AcknowledgementsView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/17/23.
//

import SwiftUI

struct AcknowledgementsView: View {
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                Text("QR Pop is made possible thanks to the generosity of several third-party open source software developers. Listed below you will find the copyright year, developer name, and license associated with each software package in use by QR Pop.")
                
                Group {
                    Divider()
                        .padding(.vertical)
                    
                    Text("Disclaimers")
                        .font(.title)
                        .bold()
                    Text("X is a registered trademark of [X Corp](https://about.twitter.com/en).")
                    Text("WhatsApp is a registered trademark of [Meta](https://about.meta.com/brand/resources/).")
                    Text("QR Code is a registered trademark of [DENSO WAVE](https://www.qrcode.com/en/)")
                }
                
                Group {
                    Divider()
                        .padding(.vertical)
                    Text("QRCode")
                        .font(.title)
                        .bold()
                    Text("[View on GitHub](https://github.com/dagronf/QRCode)")
                        .padding(.bottom)
                    Text("Copyright © 2023 Darren Ford")
                    Text(MIT_LICENSE)
                }
                
                Group {
                    Divider()
                        .padding(.vertical)
                    Text("QRCode.JS")
                        .font(.title)
                        .bold()
                    Text("[View on GitHub](https://github.com/davidshimjs/qrcodejs)")
                        .padding(.bottom)
                    Text("Copyright © 2012 davidshimjs")
                    Text(MIT_LICENSE)
                }
                
                Group {
                    Divider()
                        .padding(.vertical)
                    Text("PagerTabStripView")
                        .font(.title)
                        .bold()
                    Text("[View on GitHub](https://github.com/xmartlabs/PagerTabStripView)")
                        .padding(.bottom)
                    Text("Copyright © 2020 Xmartlabs SRL")
                    Text(MIT_LICENSE)
                }
                
                Group {
                    Divider()
                        .padding(.vertical)
                    Text("Connections")
                        .font(.title)
                        .bold()
                    Text("[View on GitHub](https://github.com/SwiftUI-Plus/Connections)")
                        .padding(.bottom)
                    Text("Copyright © 2021 Shaps Benkau")
                    Text(MIT_LICENSE)
                }
            }
            .padding()
        }
        .navigationTitle("Acknowledgements")
    }
    
    let MIT_LICENSE = """
        Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
        
        The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
        
        THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
        """
}

struct AcknowledgementsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AcknowledgementsView()
        }
    }
}

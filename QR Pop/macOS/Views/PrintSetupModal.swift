//
//  PrintSetupModal.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 12/22/21.
//

import SwiftUI
import Cocoa

struct PrintSetupModal: View {
    @EnvironmentObject var qrCode: QRCode
    
    @State private var numberOfCopies: Int = 1
    @State private var scaleCodes: Bool = true
    @State private var centerCodes: Bool = true
    
    public func print() {
        let view = NSHostingView(rootView: PrintSetupModal())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Stepper("Codes per page", value: $numberOfCopies)
            Toggle("Scale codes to fill page", isOn: $scaleCodes)
                .toggleStyle(.switch)
            Toggle("Center codes on page", isOn: $centerCodes)
                .toggleStyle(.switch)
        }.toolbar(content: {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {}) {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {}) {
                    Text("Print")
                }
            }
        })
    }
}

struct PrintSetupModal_Previews: PreviewProvider {
    static var previews: some View {
        PrintSetupModal()
    }
}

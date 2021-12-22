//
//  QRCodeDesigner.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/18/21.
//
import SwiftUI

/// A panel of design elements to customize a QR code
struct QRCodeDesigner: View {
    @EnvironmentObject var qrCode: QRCode
    
    @State var showOverlayPicker: Bool = false
    @State private var warningVisible: Bool = false
    @State private var showPicker: Bool = false
    
    var body: some View {
        VStack {
            if warningVisible {
                HStack(alignment: .center, spacing: 15) {
                    Image(systemName: "eye.trianglebadge.exclamationmark")
                        .font(.largeTitle)
                    VStack(alignment: .leading) {
                        Text("The background and foreground colors are too similar.")
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("This code may not scan. Consider picking colors with more contrast.")
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }.foregroundColor(Color("WarningLabel"))
                .frame(maxWidth: 350)
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color("WarningBkg"))
                        .padding(5)
                )
                .animation(.spring(), value: warningVisible)
                .padding()
            }
            VStack(alignment: .center, spacing: 10) {
                ColorPicker("Background color", selection: $qrCode.backgroundColor, supportsOpacity: true)
                ColorPicker("Foreground color", selection: $qrCode.foregroundColor, supportsOpacity: false)
            }.padding(.horizontal, 20)
            .onChange(of: [qrCode.backgroundColor, qrCode.foregroundColor], perform: {_ in
                qrCode.generate()
                evaluateContrast()
            }).padding(.vertical)
        }
        #if os(macOS)
        .onAppear(perform: {
            evaluateContrast()
        })
        #endif
    }
    
    private func evaluateContrast() {
        let cRatio = qrCode.backgroundColor.contrastRatio(with: qrCode.foregroundColor)
        if cRatio < 2.5 {
            withAnimation {
                warningVisible = true
            }
        } else {
            withAnimation {
                warningVisible = false
            }
        }
    }
}

//
//  QRCodeDesigner.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/18/21.
//
import SwiftUI

/// A panel of design elements to customize a QR code
struct QRCodeDesigner: View {
    @Binding var bgColor: Color
    @Binding var fgColor: Color
    @State var warningVisible: Bool = false
    
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
                ColorPicker("Background color", selection: $bgColor, supportsOpacity: false)
                ColorPicker("Foreground color", selection: $fgColor, supportsOpacity: false)
            }.padding(.horizontal, 20)
            .onChange(of: [bgColor, fgColor], perform: {_ in
                evaluateContrast()
            }).padding(.vertical)
        }
        #if os(macOS)
        .onAppear(perform: {
            evaluateContrast()
        })
        #endif
    }
    
    func evaluateContrast() {
        let cRatio = bgColor.contrastRatio(with: fgColor)
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

struct QRCodeDesigner_Previews: PreviewProvider {
    @State static var bg: Color = .white
    @State static var fg: Color = .black
    static var previews: some View {
        QRCodeDesigner(bgColor: $bg, fgColor: $fg)
    }
}

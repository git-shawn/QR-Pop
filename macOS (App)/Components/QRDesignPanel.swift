//
//  QRDesignPanel.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 10/23/21.
//

import SwiftUI

struct QRDesignPanel: View {
    @Binding var bg: Color
    @Binding var fg: Color
    @State var warningVisible: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if warningVisible {
                VStack {
                    Text("Warning! ")
                        .bold()
                        .foregroundColor(.gray)
                        .colorMultiply(.red)
                    Text("This code may not scan. Consider picking colors with more contrast.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .colorMultiply(.red)
                }.frame(width: 150)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.red)
                        .brightness(0.4)
                        .padding(5)
                )
                .animation(.spring())
            }
            ColorPicker(selection: $bg, supportsOpacity: true) {
                Text("Background Color")
                    .frame(width: 120, alignment: .leading)
            }
            ColorPicker(selection: $fg, supportsOpacity: false) {
                Text("Foreground Color")
                    .frame(width: 120, alignment: .leading)
            }.onChange(of: [bg, fg], perform: {_ in
                evaluateContrast()
            })
        }
    }
    
    func evaluateContrast() {
        let cRatio = bg.contrastRatio(with: fg)
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

struct QRDesignPanel_Previews: PreviewProvider {
    @State static var bg: Color = .white
    @State static var fg: Color = .black
    static var previews: some View {
        QRDesignPanel(bg: $bg, fg: $fg)
            
    }
}

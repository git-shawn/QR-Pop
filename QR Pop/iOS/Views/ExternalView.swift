//
//  ExternalView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 2/24/22.
//

import SwiftUI

struct ExternalView: View {
    @EnvironmentObject var externalDisplayContent: ExternalDisplayContent

    var body: some View {
        if externalDisplayContent.codeImage != nil {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    externalDisplayContent.codeImage?.swiftImage!
                    Spacer()
                }
                Spacer()
            }.background(externalDisplayContent.backgroundColor)
        } else {
            GeometryReader { geometry in
                VStack(alignment: .center) {
                    Spacer()
                        HStack(spacing: 20) {
                            Spacer()
                            Image("altAppIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: geometry.size.height/2)
                                .foregroundColor(.white)
                                .padding()
                            Text("QR POP!")
                                .font(.system(size: 150, weight: .black, design: .default))
                                .foregroundColor(.white)
                                .padding()
                            Spacer()
                        }
                    Spacer()
                }.background(Color.accentColor)
            }
        }
    }

}

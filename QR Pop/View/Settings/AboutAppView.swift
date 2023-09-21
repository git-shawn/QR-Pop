//
//  AboutAppView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/12/23.
//
#if os(macOS)

import SwiftUI

struct AboutAppView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image("Preview-AppIcon-Mac")
                .resizable()
                .scaledToFit()
                .frame(width: 144)
                .mask {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                }
                .shadow(radius: 10)
                .shadow(color: .accentColor.opacity(0.2), radius: 30)
            
            Text("QR Pop")
                .font(.largeTitle)
                .bold()
                .padding(.vertical)
            
            Text(verbatim: "Version \(Constants.releaseVersionNumber) (\(Constants.buildVersionNumber))\n© 2021 — \(Calendar.current.component(.year, from: .now))\nShawn Davis")
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Link("Source Code \(Image(systemName: "arrow.up.forward"))", destination: URL(string: "https://github.com/git-shawn/QR-Pop")!)
                .buttonStyle(.bordered)
                .foregroundColor(.accentColor)
                .padding(.vertical)
        }
        .frame(width: 250, height: 400)
        .windowMaterial(material: .sidebar)
    }
}

struct AboutAppView_Previews: PreviewProvider {
    static var previews: some View {
        AboutAppView()
    }
}

#endif

//
//  MainContentView.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 9/29/21.
//

import SwiftUI

struct MainContentView: View {
    var body: some View {
        NavigationView {
            Sidebar()
            VStack() {
                Image(systemName: "qrcode")
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(.accentColor)
                Text("Welcome to QR Pop!\nTurn URLs into QR codes anywhere.")
                    .padding()
                    .multilineTextAlignment(.center)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }.toolbar() {
                Spacer()
            }
        }.navigationTitle("QR Pop")
            .frame(minWidth: 900, idealWidth: 950, minHeight: 400, idealHeight: 550)
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}

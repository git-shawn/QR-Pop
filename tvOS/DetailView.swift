//
//  DetailView.swift
//  QR Pop TV
//
//  Created by Shawn Davis on 5/26/23.
//

import SwiftUI

struct DetailView: View {
    let model: QRModel
    @State private var showDetails: Bool = false
    
    var body: some View {
        HStack {
            QRCodeView(qrcode: .constant(model))
                .focusable()
                .contextMenu(menuItems: {
                    Button(showDetails ? "Hide Details" : "Show Details", action: {
                        withAnimation {
                            showDetails.toggle()
                        }
                    })
                    Button("Cancel", role: .cancel, action: {})
                })
            
            if showDetails {
                VStack(alignment: .leading, spacing: 10) {
                    Text(model.title ?? "QR Code")
                        .lineLimit(2)
                        .font(.largeTitle)
                        .bold()
                    Text("\(model.content.builder.title) QR Code")
                    Text("Created \(model.created ?? Date(), style: .date)")
                        .foregroundColor(.secondary)
                }
                .padding(40)
                .frame(width: 600, height: 500, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .fill(.quaternary)
                )
                .transition(.move(edge: .trailing))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(model.design.pixelColor, ignoresSafeAreaEdges: .all)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(model: QRModel())
    }
}

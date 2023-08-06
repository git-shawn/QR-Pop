//
//  ArchiveView.swift
//  QR Pop TV
//
//  Created by Shawn Davis on 5/26/23.
//

import SwiftUI

struct ArchiveView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .forward)]) var archivedCodes: FetchedResults<QREntity>
    @State private var showHelpSheet: Bool = false
    
    let columns = [
        GridItem(.adaptive(minimum: 300))
    ]
    
    var body: some View {
        if !archivedCodes.isEmpty {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(archivedCodes) { entity in
                        if let model = try? QRModel(withEntity: entity) {
                            NavigationLink(value: model, label: {
                                VStack {
                                    QRCodeView(qrcode: .constant(model))
                                    Text(model.title ?? "QR Code")
                                    Text((model.created ?? Date()), style: .date)
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                                .scenePadding()
                            })
                            .buttonStyle(.card)
                        }
                    }
                }
                .scenePadding(.horizontal)
            }
        } else {
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.icloud")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom)
                Text("Your Archive is Empty")
                    .font(.title2)
                    .bold()
                Text("No QR codes were found in your QR Pop Archive.")
                    .foregroundColor(.secondary)
                Button("Visit Support", action: { showHelpSheet.toggle() })
                    .buttonStyle(.plain)
            }
            .sheet(isPresented: $showHelpSheet, content: {
                VStack(alignment: .center, spacing: 30) {
                    Text("Support Article")
                        .font(.largeTitle)
                        .bold()
                    QRCodeView(design: .constant(DesignModel()), builder: .constant(BuilderModel(text: "https://www.fromshawn.dev/support/qrpop-tv-help")))
                    Text("Scan for Support")
                }
            })
        }
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView()
    }
}

//
//  RootView.swift
//  QR Pop TV
//
//  Created by Shawn Davis on 5/25/23.
//

import SwiftUI

struct RootView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .forward)]) var archivedCodes: FetchedResults<QREntity>
    @State private var query: String = ""
    
    let columns = [
        GridItem(.adaptive(minimum: 300))
    ]
    
    var body: some View {
        NavigationStack {
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
                            })
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button("Delete", role: .destructive, action: {
                                    
                                })
                            }
                        }
                    }
                }
                .scenePadding(.horizontal)
            }
//            Switching from search bar to LazyVGrid list causes a precondition failure. This is likely a SwiftUI bug.
//            .searchable(text: $query)
            .navigationDestination(for: QRModel.self, destination: { model in
                DetailView(model: model)
            })
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}

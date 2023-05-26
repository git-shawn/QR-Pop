//
//  SearchView.swift
//  QR Pop TV
//
//  Created by Shawn Davis on 5/26/23.
//

import SwiftUI

struct SearchView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.title, order: .forward)]) var archivedCodes: FetchedResults<QREntity>
    
    @State private var filteredArchive: [QREntity] = []
    @State private var query: String = ""
    
    var body: some View {
        List(filteredArchive) { entity in
            if let model = try? QRModel(withEntity: entity) {
                NavigationLink(value: model, label: {
                    HStack {
                        QRCodeView(qrcode: .constant(model))
                            .frame(height: 150)
                        
                        VStack(alignment: .leading) {
                            Text(model.title ?? "QR Code")
                            Text(model.created ?? Date(), style: .date)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .scenePadding(.vertical)
                })
            }
        }
        .searchable(text: $query)
        .onChange(of: query, perform: { query in
            filteredArchive = archivedCodes.filter({
                $0.title?.lowercased().contains(query.lowercased()) ?? false
            })
        })
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

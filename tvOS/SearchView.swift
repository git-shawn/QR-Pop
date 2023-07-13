//
//  SearchView.swift
//  QR Pop TV
//
//  Created by Shawn Davis on 5/26/23.
//

import SwiftUI
import Combine

struct SearchView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.title, order: .forward)]) var archivedCodes: FetchedResults<QREntity>
    
    @State private var filteredArchive: [QREntity] = []
    @StateObject private var debouncedQuery = DebouncedQuery()
    
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
        .searchable(text: $debouncedQuery.text)
        .onChange(of: debouncedQuery.debouncedText, perform: { query in
            filteredArchive = archivedCodes.filter({
                $0.title?.lowercased().contains(query.lowercased()) ?? false
            })
        })
    }
}

private class DebouncedQuery: ObservableObject {
    @Published var text: String = ""
    @Published var debouncedText: String = ""
    private var bag = Set<AnyCancellable>()

    public init(dueTime: TimeInterval = 0.5) {
        $text
            .removeDuplicates()
            .debounce(for: .seconds(dueTime), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                self?.debouncedText = value
            })
            .store(in: &bag)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

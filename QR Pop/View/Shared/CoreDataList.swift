//
//  CoreDataList.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/13/23.
//

import SwiftUI

struct CoreDataList<FetchedEntity: Entity>: View {
    var fetchedItems: [FetchedEntity]
    @State private var filteredEntities: [FetchedEntity]
    @State private var searchQuery: String = ""
    var selectAction: (FetchedEntity) -> Void
    var deleteAction: (FetchedEntity) -> Void
    
    @AppStorage("dataListSortType", store: .appGroup) private var sort: SortType = .titleAscending
    @AppStorage("dataListShowViewed", store: .appGroup) private var showViewed = false
    
    @State private var entityToRename: FetchedEntity?
    @State private var isRenamingEntity = false
    @State private var newTitle = ""
    
    @Environment(\.managedObjectContext) var moc
    
    init(fetchedItems: [FetchedEntity], selectAction: @escaping (FetchedEntity) -> Void, deleteAction: @escaping (FetchedEntity) -> Void) {
        self.fetchedItems = fetchedItems
        self.selectAction = selectAction
        self.deleteAction = deleteAction
        
        // Pre-sort
        let defaultSort = SortType(rawValue: UserDefaults.appGroup.integer(forKey: "dataListSortType"))
        self._filteredEntities = State(wrappedValue: CoreDataList.sortEntities(fetchedItems, by: defaultSort ?? .createdLatest))
    }
    
    var body: some View {
        List {
            ForEach(filteredEntities, id: \.id) { item in
                Button(action: {
                    selectAction(item)
                }, label: {
                    VStack {
                        HStack(spacing: 14) {
                            if let data = item.design, let model = try? DesignModel(decoding: data, with: item.logo) {
                                QRCodeView(qrcode: .constant(QRModel(design: model, content: BuilderModel())))
                                    .frame(width: 52, height: 52)
#if os(macOS)
                                    .padding(.leading)
#endif
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title ?? "QR Code")
                                    .foregroundColor(.primary)
                                Text("\((showViewed ? item.viewed : item.created ) ?? Date(), format: Date.FormatStyle(date: .numeric, time: .shortened))")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.forward")
                                .foregroundColor(.tertiaryLabel)
                        }
#if os(macOS)
                        Divider()
#endif
                    }
                    .contentShape(Rectangle())
                })
                .buttonStyle(.plain)
                .contextMenu {
                    ImageButton("Rename", systemImage: "pencil", action: {
                        newTitle = item.title ?? "QR Code"
                        entityToRename = item
                        isRenamingEntity = true
                    })
                    Divider()
                    ImageButton("Delete", systemImage: "trash", role: .destructive, action: {
                        deleteAction(item)
                    })
                }
                .swipeActions {
                    ImageButton("Delete", systemImage: "trash", role: .destructive, action: {
                        deleteAction(item)
                    })
                    
                    ImageButton("Rename", systemImage: "pencil", action: {
                        newTitle = item.title ?? "QR Code"
                        entityToRename = item
                        isRenamingEntity = true
                    })
                    .tint(.indigo)
                }
            }
        }
        .listStyle(.plain)
        .onChange(of: sort) { sort in
            filteredEntities = CoreDataList.sortEntities(filteredEntities, by: sort)
        }
        .onChange(of: fetchedItems) { newItems in
            filteredEntities = CoreDataList.sortEntities(newItems, by: sort)
        }
        .refreshable {
            filteredEntities = CoreDataList.sortEntities(fetchedItems, by: sort)
        }
        
        // MARK: - Toolbar
        
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .status) {
                Text("\(fetchedItems.count) Entries")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
#endif
            ToolbarItem(placement: .primaryAction) {
                Menu(content: {
                    Button(action: {
                        if sort == .titleDescending {
                            sort = .titleAscending
                        } else {
                            sort = .titleDescending
                        }
                    }, label: {
                        HStack {
                            Text("Title")
                            if sort == .titleAscending {
                                Image(systemName: "chevron.up")
                            } else if sort == .titleDescending {
                                Image(systemName: "chevron.down")
                            }
                        }
                    })
                    
                    Button(action: {
                        if sort == .createdLatest {
                            sort = .createdOldest
                        } else {
                            sort = .createdLatest
                        }
                    }, label: {
                        HStack {
                            Text("Date Created")
                            if sort == .createdLatest {
                                Image(systemName: "chevron.up")
                            } else if sort == .createdOldest {
                                Image(systemName: "chevron.down")
                            }
                        }
                    })
                    
                    Button(action: {
                        if sort == .viewedLatest {
                            sort = .viewedOldest
                        } else {
                            sort = .viewedLatest
                        }
                    }, label: {
                        HStack {
                            Text("Date Viewed")
                            if sort == .viewedLatest {
                                Image(systemName: "chevron.up")
                            } else if sort == .viewedOldest {
                                Image(systemName: "chevron.down")
                            }
                        }
                    })
                    
                    Divider()
                    
                    Menu("View Options") {
                        
                        Button(action: {
                            showViewed = false
                        }, label: {
                            HStack {
                                Text("Show Created Date")
                                if !showViewed {
                                    Image(systemName: "checkmark")
                                }
                            }
                        })
                        
                        Button(action: {
                            showViewed = true
                        }, label: {
                            HStack {
                                Text("Show Last Viewed")
                                if showViewed {
                                    Image(systemName: "checkmark")
                                }
                            }
                        })
                    }
                }, label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down.circle")
#if os(macOS)
                        .labelStyle(.titleOnly)
#endif
                })
#if os(macOS)
                .help("Change the item sorting as well as whether to show the \"Created\" date or \"Last Viewed\" date.")
#endif
            }
        }
        
        // MARK: - Searchable
        
        .searchable(text: $searchQuery, prompt: Text("Search by Title"))
        .onChange(of: searchQuery) { query in
            filteredEntities = fetchedItems.filter {
                guard !searchQuery.isEmpty else { return true }
                return ($0.title ?? "QR Code").lowercased().contains(searchQuery.lowercased())
            }
        }
        
        // MARK: - Rename
        .alert("Rename", isPresented: $isRenamingEntity, actions: {
            TextField("Title", text: $newTitle)
            Button("Cancel", role: .cancel, action: {
                isRenamingEntity = false
            })
            Button("Save", action: {
                do {
                    entityToRename?.title = newTitle
                    newTitle = ""
                    try moc.save()
                } catch let error {
                    debugPrint(error)
                }
            })
            .disabled(newTitle.isEmpty)
        })
    }
}

// MARK: - Sort Fetched Items

extension CoreDataList {
    
    static func sortEntities(_ filteredEntities: [FetchedEntity], by sort: SortType) -> [FetchedEntity] {
        switch sort {
        case .createdLatest:
            return filteredEntities.sorted(by: { $0.created ?? Date() > $1.created ?? Date() })
        case .createdOldest:
            return filteredEntities.sorted(by: { $0.created ?? Date() < $1.created ?? Date() })
        case .viewedLatest:
            return filteredEntities.sorted(by: { $0.viewed ?? Date() > $1.viewed ?? Date() })
        case .viewedOldest:
            return filteredEntities.sorted(by: { $0.viewed ?? Date() < $1.viewed ?? Date() })
        case .titleAscending:
            return filteredEntities.sorted(by: { ($0.title ?? "QR Code").localizedStandardCompare($1.title ?? "QR Code") == .orderedAscending })
        case .titleDescending:
            return filteredEntities.sorted(by: { ($0.title ?? "QR Code").localizedStandardCompare($1.title ?? "QR Code") == .orderedDescending })
        }
    }
    
    enum SortType: Int {
        case createdLatest, createdOldest, viewedLatest, viewedOldest, titleAscending, titleDescending
    }
}

struct CoreDataList_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
            .environment(\.managedObjectContext, Persistence.shared.container.viewContext)
    }
    
    struct PreviewWrapper: View {
        @State private var fetchedItems = try! Persistence.shared.getAllQREntities()
        
        var body: some View {
            NavigationStack {
                CoreDataList(fetchedItems: fetchedItems, selectAction: { entity in
                    print("\(entity.title ?? "No title?") selected!")
                }, deleteAction: { entity in
                    fetchedItems.removeAll(where: {$0.id == entity.id})
                })
                .navigationTitle("My List")
            }
        }
        
    }
}

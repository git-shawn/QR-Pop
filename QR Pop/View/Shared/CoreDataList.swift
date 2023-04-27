//
//  CoreDataList.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/13/23.
//

import SwiftUI
import OSLog

struct CoreDataList<FetchedEntity: Entity>: View {
    var fetchedItems: [FetchedEntity]
    @State private var filteredEntities: [FetchedEntity]
    @State private var searchQuery: String = ""
    var selectAction: (FetchedEntity) -> Void
    let entityType: Persistence.EntityType
    
    @AppStorage("dataListSortType", store: .appGroup) private var sort: SortType = .titleAscending
    
    @State private var entityToRename: FetchedEntity?
    @State private var isRenamingEntity = false
    @State private var newTitle = ""
    
    @State private var isEditing: Bool = false
    @State private var selectedEntities: [FetchedEntity] = []
    
    @Environment(\.managedObjectContext) var moc
    
    init(
        entityType: Persistence.EntityType,
        fetchedItems: [FetchedEntity],
        selectAction: @escaping (FetchedEntity) -> Void)
    {
        self.fetchedItems = fetchedItems
        self.selectAction = selectAction
        self.entityType = entityType
        
        // Pre-sort
        let defaultSort = SortType(rawValue: UserDefaults.appGroup.integer(forKey: "dataListSortType"))
        self._filteredEntities = State(wrappedValue: CoreDataList.sortEntities(fetchedItems, by: defaultSort ?? .createdLatest))
    }
    
    var body: some View {
        List {
            ForEach(filteredEntities, id: \.id) { item in
                HStack(spacing: 10) {
                    ZStack {
                        if isEditing {
                            Button(action: {
                                if let index = selectedEntities.firstIndex(of: item) {
                                    selectedEntities.remove(at: index)
                                } else {
                                    selectedEntities.append(item)
                                }
                            }, label: {
                                ZStack {
                                    if selectedEntities.contains(item) {
                                        Label("Deselect", systemImage: "checkmark.circle.fill")
                                            .foregroundColor(.accentColor)
                                    } else {
                                        Label("Select", systemImage: "circle")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .imageScale(.large)
                                .labelStyle(.iconOnly)
                                .buttonStyle(.plain)
                            })
                            .buttonStyle(.plain)
                        }
                    }
                    .transition(.push(from: .leading))
                    
                    Button(action: {
                        selectAction(item)
                    }, label: {
                        VStack {
                            HStack(spacing: 14) {
                                if let data = item.design, let model = try? DesignModel(decoding: data, with: item.logo) {
                                    QRCodeView(qrcode: .constant(QRModel(design: model, content: BuilderModel())))
                                        .frame(width: 52, height: 52)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title ?? "QR Code")
                                        .foregroundColor(.primary)
                                    Text("\(item.created ?? Date(), format: Date.FormatStyle(date: .numeric, time: .shortened))")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.forward")
                                    .foregroundColor(.tertiaryLabel)
                            }
                        }
                        .contentShape(Rectangle())
                    })
                    .disabled(isEditing)
                    .buttonStyle(.plain)
                }
                .contextMenu {
                    ImageButton("Rename", systemImage: "pencil", action: {
                        newTitle = item.title ?? "QR Code"
                        entityToRename = item
                        isRenamingEntity = true
                    })
                    Divider()
                    ImageButton("Delete", systemImage: "trash", role: .destructive, action: {
                        deleteItems([item])
                    })
                }
                .swipeActions {
                    ImageButton("Delete", systemImage: "trash", role: .destructive, action: {
                        deleteItems([item])
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
#if os(iOS)
        .listStyle(.plain)
#else
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .environment(\.defaultMinListRowHeight, 64)
#endif
        .onChange(of: sort) { sort in
            filteredEntities = CoreDataList.sortEntities(filteredEntities, by: sort)
        }
        .onChange(of: fetchedItems) { newItems in
            Logger.logView.debug("CoreDataList: FetchedItems has changed, likely via CloudKit.")
            filteredEntities = CoreDataList.sortEntities(newItems, by: sort)
        }
        
        // MARK: - Toolbar
        
        .toolbar {
#if os(iOS)
            ToolbarItemGroup(placement: .bottomBar) {
                sortButton
                Spacer()
                if !isEditing {
                    Text("\(fetchedItems.count) Entries")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    Text("\(selectedEntities.count) Selected")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Trash", role: .destructive, action: {
                        withAnimation {
                            deleteItems(selectedEntities)
                            isEditing.toggle()
                        }
                    })
                    .disabled(selectedEntities.isEmpty)
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                editButton
            }
#else
            ToolbarItemGroup(placement: .primaryAction) {
                sortButton
                editButton
            }
            
            ToolbarItemGroup(placement: .optionsBar) {
                if isEditing {
                    ImageButton("Trash", systemImage: "trash", role: .destructive, action: {
                        withAnimation {
                            deleteItems(selectedEntities)
                            isEditing.toggle()
                        }
                    })
                    .labelStyle(.titleAndIcon)
                    .disabled(selectedEntities.isEmpty)
                }
            }
#endif
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
                    try moc.atomicSave()
                } catch let error {
                    debugPrint(error)
                }
            })
            .disabled(newTitle.isEmpty)
        })
    }
    
    // MARK: - Sort Button
    
    var sortButton: some View {
        Menu(content: {
            
            Menu(content: {
                Button("Alphabetically", action: {
                    sort = .titleAscending
                })
                
                Button("Reversed", action: {
                    sort = .titleDescending
                })
            }, label: {
                Label("By Title", systemImage: "checkmark")
                    .labelStyle(SelectedLabelStyle(sort == .titleAscending || sort == .titleDescending))
            })
            
            Menu(content: {
                Button("Newest", action: {
                    sort = .createdLatest
                })
                Button("Oldest", action: {
                    sort = .createdOldest
                })
            }, label: {
                Label("By Created", systemImage: "checkmark")
                    .labelStyle(SelectedLabelStyle(sort == .createdLatest || sort == .createdOldest))
            })
        }, label: {
            Text("Sort")
        })
        .environment(\.menuOrder, .fixed)
#if os(macOS)
        .help("Sort this list either alphabetically or by date created.")
#endif
    }
    
    // MARK: - Edit Button
    
    var editButton: some View {
        
        Button(action: {
            withAnimation {
                isEditing.toggle()
                if !isEditing {
                    selectedEntities = []
                }
            }
        }, label: {
            ZStack {
                if isEditing {
                    Text("Cancel")
                        .bold()
                } else {
                    Text("Edit")
                }
            }
            .transaction { $0.animation = nil }
        })
    }
}

// MARK: - Delete Fetched Items

extension CoreDataList {
    
    func deleteItems(_ items: [FetchedEntity]) {
        do {
            try Persistence.shared.deleteEntities(items, of: entityType)
        } catch {
            Logger.logView.error("CoreDataList: Failed to delete \(items.count, privacy: .public) \(entityType.rawValue, privacy: .public) items from from the database.")
        }
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
        case .titleAscending:
            return filteredEntities.sorted(by: { ($0.title ?? "QR Code").localizedStandardCompare($1.title ?? "QR Code") == .orderedAscending })
        case .titleDescending:
            return filteredEntities.sorted(by: { ($0.title ?? "QR Code").localizedStandardCompare($1.title ?? "QR Code") == .orderedDescending })
        }
    }
    
    enum SortType: Int {
        case createdLatest, createdOldest, titleAscending, titleDescending
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
                CoreDataList(
                    entityType: .archive,
                    fetchedItems: fetchedItems,
                    selectAction: { entity in
                        print("\(entity.title ?? "No title?") selected!")
                    })
                .navigationTitle("My List")
            }
        }
        
    }
}

// MARK: - Selected Button Modifier

struct SelectedLabelStyle: LabelStyle {
    var isSelected: Bool
    
    init(_ isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
#if os(iOS)
            if isSelected {
                configuration.icon
            }
#endif
            configuration.title
        }
    }
}


#if os(macOS)
// MARK: - Secondary Toolbar Row

extension ToolbarItemPlacement {
    static let optionsBar = ToolbarItemPlacement(id: "shwndvs.coreDataSheetEditingOptions")
}

#endif
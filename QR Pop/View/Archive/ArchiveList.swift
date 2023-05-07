//
//  ArchiveList.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI

struct ArchiveList: View {
    @FetchRequest(sortDescriptors: []) var archive: FetchedResults<QREntity>
    @EnvironmentObject var sceneModel: SceneModel
    @EnvironmentObject var navigationModel: NavigationModel
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        ZStack {
            if archive.isEmpty {
                VStack {
                    ZStack {
                        Image(systemName: "archivebox")
                            .resizable()
                            .foregroundColor(.placeholder)
                            .scaledToFit()
                            .padding()
                    }
                    .frame(width: 150, height: 150)
                    Text("Your Archive is Empty")
                        .foregroundColor(.placeholder)
                }
            } else {
                CoreDataList<QREntity>(
                    entityType: .archive,
                    fetchedItems: Array(archive),
                    selectAction: { entity in
                        do {
                            let model = try entity.asModel()
                            navigationModel.navigate(to: .archive(code: model))
                        } catch {
                            sceneModel.toaster = .error(note: "Could not open")
                        }
                    })
            }
        }
        .navigationTitle("Archive")
    }
}

struct ArchiveList_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button("Add Entity", action: {
                var model = QRModel()
                model.design.backgroundColor = Color.random
                let entity = QREntity(context: Persistence.shared.container.viewContext)
                entity.title = "New Entity"
                entity.id = UUID()
                entity.created = Date()
                entity.logo = nil
                entity.builder = try? model.content.asData()
                entity.design = try? model.design.asData()
                try? Persistence.shared.container.viewContext.atomicSave()
            })
            
            ArchiveList()
        }
        .environment(\.managedObjectContext, Persistence.shared.container.viewContext)
        
        ArchiveList()
            .previewDisplayName("Empty List")
    }
}

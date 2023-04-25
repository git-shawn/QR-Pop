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
        CoreDataList<QREntity>(
            fetchedItems: Array(archive),
            selectAction: { entity in
                do {
                    entity.viewed = Date()
                    let model = try QRModel(withEntity: entity)
                    navigationModel.navigate(to: .archive(code: model))
                } catch let error {
                    debugPrint(error)
                    Constants.viewLogger.error("Could not navigate to QREntity in ArchiveList.")
                    sceneModel.toaster = .error(note: "Could not open")
                }
            },
            deleteAction: { entity in
                do {
                    moc.delete(entity)
                    try moc.save()
                } catch let error {
                    debugPrint(error)
                    Constants.viewLogger.error("QREntity could not be deleted")
                    sceneModel.toaster = .error(note: "QR code could not delete")
                }
            })
        .navigationTitle("Archive")
        .overlay(
            VStack {
                if archive.isEmpty {
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
            }
        )
    }
}

struct ArchiveList_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button("Add Entity", action: {
                var model = QRModel()
                model.design.backgroundColor = Color.random
                print(model.design.backgroundColor)
                let entity = QREntity(context: Persistence.shared.container.viewContext)
                entity.title = "New Entity"
                entity.id = UUID()
                entity.viewed = Date()
                entity.created = Date()
                entity.logo = nil
                entity.builder = try? model.content.asData()
                entity.design = try? model.design.asData()
                try? Persistence.shared.container.viewContext.save()
            })
            
            ArchiveList()
        }
        .environment(\.managedObjectContext, Persistence.shared.container.viewContext)
        
        ArchiveList()
            .previewDisplayName("Empty List")
    }
}

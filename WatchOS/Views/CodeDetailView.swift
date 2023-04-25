//
//  CodeDetailView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/22/23.
//

import SwiftUI
import QRCode
import OSLog

struct CodeDetailView: View {
    var entity: QREntity
    var model: QRModel
    
    @State private var tabSelection: Int = 1
    @State private var showDeleteDialog: Bool = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    init(entity: QREntity) {
        self.entity = entity
        
        do {
            self.model = try QRModel(withEntity: entity)
        } catch let error {
            debugPrint(error)
            Logger(subsystem: Constants.bundleIdentifier, category: "watch").error("Could not convert entity to model in CodeDetailView.")
            self.model = QRModel()
        }
    }
    
#if targetEnvironment(simulator)
    init() {
        self.entity = QREntity(context: Persistence.shared.container.viewContext)
        self.model = QRModel()
    }
#endif
    
    var body: some View {
        TabView(selection: $tabSelection) {
            menu.tag(0)
            code.tag(1)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Menu
    
    var menu: some View {
        ScrollView {
            let title = entity.title ?? "QR Code"
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .truncationMode(.tail)
                            .foregroundColor(.accentColor)
                            .padding(.leading)
                            .font(.title3)
                        Spacer()
                    }
                    
                    Group {
                        Text("\(model.content.builder.icon) \(model.content.builder.title) QR Code")
                        
                        Text("Created ") +
                        Text(model.created ?? Date(), style: .date)
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.leading)
                }
                Spacer()
                Button(action: {
                    dismiss()
                }, label: {
                    Label("Back to Menu", systemImage: "arrowshape.turn.up.backward")
                })
                
                ShareLink("Share Code", item: model, preview: SharePreview("\(title)", image: model))
                    .tint(.blue)
                
                Button(role: .destructive, action: {
                    showDeleteDialog = true
                }, label: {
                    Label("Delete", systemImage: "trash")
                })
                Spacer()
            }
        }
        .confirmationDialog("Delete Code from Library?", isPresented: $showDeleteDialog, actions: {
            Button("Delete", role: .destructive, action: {
                moc.delete(entity)
                try? moc.save()
                dismiss()
            })
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("This action cannot be undone.")
        })
    }
    
    // MARK: - VIEW
    
    var code: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: (15))
                .fill(model.design.backgroundColor)
                .zIndex(0)
            ZStack {
                QRCodeShape(text: model.content.result)?
                    .components(.eyeOuter)
                    .fill(model.design.eyeColor)
                QRCodeShape(text: model.content.result)?
                    .components(.eyePupil)
                    .fill(model.design.pupilColor)
                QRCodeShape(text: model.content.result)?
                    .components(.onPixels)
                    .fill(model.design.pixelColor)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(model.design.backgroundColor, ignoresSafeAreaEdges: .all)
    }
}

struct CodeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CodeDetailView()
    }
}

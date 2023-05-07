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
    @State private var brightenCode: Bool = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    init(entity: QREntity) {
        self.entity = entity
        
        do {
            self.model = try QRModel(withEntity: entity)
        } catch {
            Logger.logView.error("CodeDetailView: Could not convert entity to model.")
            self.model = QRModel()
        }
    }
    
#if targetEnvironment(simulator)
    init() {
        var design = DesignModel()
        design.backgroundColor = Color.random
        self.entity = QREntity(context: Persistence.shared.container.viewContext)
        self.model = QRModel(
            design: design,
            content: BuilderModel(text: """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin varius purus ac diam commodo auctor. Curabitur pellentesque tellus non neque facilisis luctus ut efficitur augue. Sed ullamcorper lacus augue, ac tempus enim imperdiet quis. Vivamus euismod nisi vel enim suscipit, sit amet rutrum tellus commodo. Interdum et malesuada fames ac ante ipsum primis in faucibus. Etiam viverra dictum sem, sed lobortis nibh egestas vel.
"""
                                 ))
        self.entity.title = "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
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
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .foregroundColor(.accentColor)
                            .padding(.leading)
                            .font(.title3)
                        Spacer()
                    }
                    
                    Group {
                        Text("\(model.content.builder.icon) \(model.content.builder.title)")
                        
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
                
                Button(action: {
                    brightenCode.toggle()
                }, label: {
                    Label(title: {
                        Text("Brighten Code")
                    }, icon: {
                        if brightenCode {
                            Image(systemName: "lightbulb.slash")
                        } else {
                            Image(systemName: "lightbulb")
                        }
                    })
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
                try? moc.atomicSave()
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
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(model.design.backgroundColor)
                .zIndex(0)
                .brightness(brightenCode ? 1 : 0)
            
            Canvas { context, size in
                let rect = CGRect(origin: .zero, size: size)
                if let baseShape = QRCodeShape(text: model.content.result, errorCorrection: model.design.errorCorrection) {
                        
                    if let offPixelShape = model.design.offPixels {
                            context.fill(
                                baseShape
                                    .components(.offPixels)
                                    .offPixelShape(offPixelShape.generator)
                                    .path(in: rect),
                                with: .color(model.design.pixelColor.opacity(0.2)),
                                style: .init(eoFill: true, antialiased: false)
                            )
                        }
                        
                        context.fill(
                            (baseShape
                                .components(.onPixels)
                                .onPixelShape(model.design.pixelShape.generator)
                                .path(in: rect)),
                            with: .color(model.design.pixelColor),
                            style: .init(eoFill: true, antialiased: false))
                        
                        context.fill(
                            (baseShape
                                .components(.eyeOuter)
                                .eyeShape(model.design.eyeShape.generator)
                                .path(in: rect)),
                            with: .color(model.design.eyeColor),
                            style: .init(eoFill: true, antialiased: false))
                        
                        context.fill(
                            (baseShape
                                .components(.eyePupil)
                                .eyeShape(model.design.eyeShape.generator)
                                .path(in: rect)),
                            with: .color(model.design.pupilColor),
                            style: .init(eoFill: true, antialiased: false))
                }
            }
            .zIndex(1)
            .padding(16)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#if targetEnvironment(simulator)
struct CodeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CodeDetailView()
    }
}
#endif

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
                        Text(model.content.builder.title)
                        
                        Text("Created ") +
                        Text(model.created?.formatted(.dateTime.day().month().year()) ?? "Unknown")
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.leading)
                }
                Spacer()
                
                if #available(watchOS 10.0, *) {
                    
                } else {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Label("Back to Menu", systemImage: "arrowshape.turn.up.backward")
                    })
                }
                
                Toggle(isOn: $brightenCode, label: {
                    if brightenCode {
                        Label("Restore Code", systemImage: "dial.high")
                    } else {
                        Label("Simplify Code", systemImage: "dial.low")
                    }
                })
                .toggleStyle(.button)
                
                HStack {
                    ShareLink("", item: model, preview: SharePreview("\(title)", image: model))
                        .tint(.blue)
                    
                    Button(role: .destructive, action: {
                        showDeleteDialog = true
                    }, label: {
                        Image(systemName: "trash")
                    })
                }
                Spacer()
            }
        }
        .toolbar {
            if #available(watchOS 10.0, *) {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "chevron.left")
                    })
                }
            }
        }
        .confirmationDialog("Delete Code from Library?", isPresented: $showDeleteDialog, actions: {
            Button("Delete", role: .destructive, action: {
                moc.delete(entity)
                do {
                    try moc.atomicSave()
                } catch {
                    Logger.logView.error("CodeDetailView: Entity could not be deleted.")
                }
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
                .fill(brightenCode ? .white : model.design.backgroundColor)
                .zIndex(0)
            
            Canvas { context, size in
                let rect = CGRect(origin: .zero, size: size)
                if let baseShape = QRCodeShape(text: model.content.result, errorCorrection: model.design.errorCorrection) {
                    
                    context.fill(
                        (baseShape
                            .components(.onPixels)
                            .onPixelShape(brightenCode ? QRCode.PixelShape.Square() : model.design.pixelShape.generator)
                            .path(in: rect)),
                        with: .color(brightenCode ? .black : model.design.pixelColor),
                        style: .init(eoFill: true, antialiased: true))
                    
                    context.fill(
                        (baseShape
                            .components(.eyeOuter)
                            .eyeShape(brightenCode ? QRCode.EyeShape.Square() : model.design.eyeShape.generator)
                            .path(in: rect)),
                        with: .color(brightenCode ? .black : model.design.eyeColor),
                        style: .init(eoFill: true, antialiased: true))
                    
                    context.fill(
                        (baseShape
                            .components(.eyePupil)
                            .eyeShape(brightenCode ? QRCode.EyeShape.Square() : model.design.eyeShape.generator)
                            .path(in: rect)),
                        with: .color(brightenCode ? .black : model.design.pupilColor),
                        style: .init(eoFill: true, antialiased: true))
                }
            }
            .zIndex(1)
            .padding(16)
        }
        .ignoresSafeArea(edges: .bottom)
        .toolbar {
            
        }
    }
}

#if targetEnvironment(simulator)
struct CodeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CodeDetailView()
        }
    }
}
#endif

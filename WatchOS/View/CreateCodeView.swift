//
//  CreateCodeView.swift
//  QR Pop Watch App
//
//  Created by Shawn Davis on 9/21/23.
//

import SwiftUI
import QRCode
import OSLog

@available(watchOS 10.0, *)
struct CreateCodeView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "created", ascending: false)]) var templates: FetchedResults<TemplateEntity>
    
    @State private var model = QRModel(design: DesignModel(), content: BuilderModel(for: .text))
    @State private var codeContent: String = ""
    @State private var showTempaltePicker: Bool = false
    @State private var showMenu: Bool = false
    @State private var namingCode: Bool = false
    @State private var codeName: String = ""
    @State private var couldNotSave: Bool = false
    @State private var couldSave: Bool = false
    
    var body: some View {
        Form {
            Section {
                TextField("Content", text: $codeContent)
                    .onSubmit {
                        model.content.result = codeContent
                        model.content.responses = [codeContent]
                    }
            }
            Section {
                Canvas { context, size in
                    let rect = CGRect(origin: .zero, size: size)
                    if let baseShape = QRCodeShape(text: model.content.result, errorCorrection: model.design.errorCorrection) {
                        
                        context.fill(
                            (baseShape
                                .components(.onPixels)
                                .onPixelShape(model.design.pixelShape.generator)
                                .path(in: rect)),
                            with: .color(model.design.pixelColor),
                            style: .init(eoFill: true, antialiased: true))
                        
                        context.fill(
                            (baseShape
                                .components(.eyeOuter)
                                .eyeShape(model.design.eyeShape.generator)
                                .path(in: rect)),
                            with: .color(model.design.eyeColor),
                            style: .init(eoFill: true, antialiased: true))
                        
                        context.fill(
                            (baseShape
                                .components(.eyePupil)
                                .eyeShape(model.design.eyeShape.generator)
                                .path(in: rect)),
                            with: .color(model.design.pupilColor),
                            style: .init(eoFill: true, antialiased: true))
                    }
                }
                .padding()
                .padding(.vertical, 1)
                .scaledToFit()
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(model.design.backgroundColor)
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if model.title == nil {
                    Button(action: {
                        showMenu.toggle()
                    }, label: {
                        Image(systemName: "ellipsis")
                            .help("Menu")
                    })
                } else {
                    ShareLink(item: model, preview: SharePreview("QR Code", image: model))
                }
            }
            ToolbarItem(placement: .bottomBar) {
                if model.title == nil {
                    HStack {
                        Spacer()
                        Button(action: {
                            showTempaltePicker.toggle()
                        }, label: {
                            Image(systemName: "paintbrush")
                                .help("Pick Template")
                        })
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(model.title ?? "New Code")
        .alert("Archived", isPresented: $couldSave, actions: {}, message: {
            Text("\"\(model.title ?? "My QR Code")\" has been saved to your archive.")
        })
        .alert("Could Not Save", isPresented: $couldNotSave, actions: {}, message: {
            Text("Your QR code could not be saved to the archive.")
        })
        .sheet(isPresented: $showTempaltePicker) {
            NavigationStack {
                List {
                    if templates.isEmpty {
                        VStack(alignment: .center, spacing: 6) {
                            Text("No Templates")
                                .bold()
                            Text("Templates you create in QR Pop will appear here.")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                        }
                        .listRowBackground(Color.clear)
                    }
                    ForEach(templates) { template in
                        let designModel = try? DesignModel(decoding: template.design ?? Data())
                        Button(action: {
                            model.design = designModel ?? DesignModel()
                            showTempaltePicker = false
                        }, label: {
                            HStack {
                                QRModel(design: designModel ?? DesignModel(), content: BuilderModel(text: ""))
                                    .image(for: 64)?
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .padding(2)
                                    .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(designModel?.backgroundColor ?? .white)
                                    )
                                    .padding(.trailing)
                                Text(template.title ?? "unknown")
                            }
                        })
                    }
                }
            }
        }
        .sheet(isPresented: $namingCode) {
            VStack {
                TextField("Enter your name", text: $codeName, prompt: Text("My QR Code"))
                Button("Save", action: addCodeToArchive)
            }
        }
        .sheet(isPresented: $showMenu) {
            List {
                Section {
                    ShareLink(item: model, preview: SharePreview("QR Code", image: model))
                    Button(action: {
                        namingCode = true
                    }, label: {
                        Label("Add to Archive", systemImage: "archivebox")
                    })
                }
                Section {
                    Button(role: .destructive,
                           action: {
                        model = QRModel()
                        codeContent = ""
                        showMenu = false
                    },
                           label: {
                        Label("Reset", systemImage: "trash")
                            .foregroundStyle(.red)
                    })
                }
            }
        }
    }
    
    func addCodeToArchive() {
        if codeName.isEmpty {
            codeName = "My QR Code"
        }
        
        model.title = codeName
        
        do {
            let entity = QREntity(context: moc)
            entity.created = Date()
            entity.id = UUID()
            entity.design = try model.design.asData()
            entity.builder = try model.content.asData()
            entity.title = codeName
            try Persistence.shared.container.viewContext.atomicSave()
            namingCode = false
            showMenu = false
            Task {
                try await Task.sleep(nanoseconds: 600_000_000)
                couldSave = true
            }
        } catch {
            Logger.logView.error("CreateCodeView: Could not create and save QREntity when adding to archive.")
            namingCode = false
            showMenu = false
            Task {
                try await Task.sleep(nanoseconds: 600_000_000)
                couldNotSave = true
            }
        }
    }
}

//
//  BuilderCommands.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/24/23.
//

import SwiftUI

struct BuilderCommands: Commands {
    @FocusedBinding(\.qrModel) var model
    @FocusedBinding(\.printing) var isPrinting
    @FocusedBinding(\.archiving) var isArchiving
    @FocusedObject var sceneModel: SceneModel?
    @FocusedObject var navigationModel: NavigationModel?
    
    var body: some Commands {
        // MARK: New Item
        CommandGroup(replacing: .newItem, addition: {
            Menu("New QR Code", content: {
                ForEach(BuilderModel.Kind.allCases, id: \.rawValue) { builderKind in
                    Button(builderKind.title, action: {
                        navigationModel?.navigate(to: .builder(code: QRModel(design: DesignModel(), content: BuilderModel(for: builderKind))))
                    })
                }
            })
            .disabled(navigationModel == nil)
            
            if let recentlyArchived = try? Persistence.shared.getMostRecentQREntities(5, by: .created) {
                Menu("Open Recent Archive...", content: {
                    ForEach(recentlyArchived) { archive in
                        if let model = try? QRModel(withEntity: archive) {
                            Button(action: {
                                navigationModel?.navigate(to: .archive(code: model))
                            }, label: {
                                Label(title: {
                                    Text("\(archive.title ?? "My QR Code")")
                                }, icon: {
                                    QRModel(design: model.design, content: BuilderModel()).image(for: 64)?
                                        .resizable()
                                        .scaledToFit()
                                })
                                .labelStyle(.titleAndIcon)
                            })
                        }
                    }
                    Divider()
                    Button("View Full Archive", action: {
                        navigationModel?.navigate(to: .archive(code: nil))
                    })
                })
            }
        })
        
        
        // MARK: - Save Item
        CommandGroup(replacing: .saveItem, addition: {
            Button("Save in Archive as...", action: {
                isArchiving = true
            })
            .keyboardShortcut(.init("S"), modifiers: .command)
            .disabled(model == nil)
        })
        
        // MARK: - Print Item
        CommandGroup(replacing: .printItem, addition: {
            Button("Print", action: {
                isPrinting = true
            })
            .keyboardShortcut(.init("P"), modifiers: .command)
            .disabled(model == nil)
        })
        
        CommandGroup(after: .newItem, addition: {
            Divider()
#if os(iOS)
            Button("Add QR Code to Photos", action: {
                do {
                    try model?.addToPhotoLibrary(for: 512)
                    sceneModel?.toaster = .saved(note: "Image saved")
                } catch let error {
                    debugPrint(error)
                    sceneModel?.toaster = .error(note: "Could not save photo")
                }
            })
            .disabled(model == nil)
#endif
            
            Menu("Export QR Code", content: {
                Button("Export Image", action: {
                    guard let image = try? model?.pngData(for: 512) else {
                        sceneModel?.toaster = .error(note: "Could not save image")
                        return
                    }
                    sceneModel?.exporter = .init(
                        document: DataFileDocument(initialData: image),
                        UTType: .png,
                        defaultName: model?.title ?? "QR Code"
                    )
                })
                .keyboardShortcut(.init("E"), modifiers: [.command, .shift])
                Button("Export PDF", action: {
                    guard let pdf = try? model?.pdfData() else {
                        sceneModel?.toaster = .error(note: "Could not save image")
                        return
                    }
                    sceneModel?.exporter = .init(
                        document: DataFileDocument(initialData: pdf),
                        UTType: .pdf,
                        defaultName: model?.title ?? "QR Code"
                    )
                })
                Button("Export SVG", action: {
                    guard let svg = try? model?.svgData() else {
                        sceneModel?.toaster = .error(note: "Could not save image")
                        return
                    }
                    sceneModel?.exporter = .init(
                        document: DataFileDocument(initialData: svg),
                        UTType: .svg,
                        defaultName: model?.title ?? "QR Code"
                    )
                })
            })
            .disabled(model == nil)
            Divider()
            Button("Reset QR Code", action: {
                model?.reset()
            })
            .keyboardShortcut(.delete, modifiers: [.command, .shift])
            .disabled(model == nil)
        })
        
        CommandGroup(after: .pasteboard, addition: {
            Divider()
            Button("Copy QR Code Image", action: {
                model?.addToPasteboard(for: 512)
                sceneModel?.toaster = .copied(note: "Image copied")
            })
            .disabled(model == nil)
        })
    }
}

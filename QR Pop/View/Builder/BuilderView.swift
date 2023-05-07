//
//  BuilderView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/10/23.
//

import SwiftUI
import PagerTabStripView
import OSLog

struct BuilderView: View {
    @State var model: QRModel = QRModel()
    @State var entity: QREntity? = nil
    private var formView: some View {
        model.content.builder.getView(model: $model.content)
    }
    @EnvironmentObject var sceneModel: SceneModel
    @State private var currentPagerTab = "form"
    @State private var showingPrintSetup = false
    @State private var isNamingArchivedModel = false
    @State private var newArchiveTitle = ""
    @State private var hasMadeChanges: Bool = false
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.verticalSizeClass) var vSizeClass
    @Environment(\.managedObjectContext) var moc
    
#if os(macOS)
    @SceneStorage("designPanelWidth") var designPanelWidth: Double = 275
#endif
    
    var body: some View {
        VStack(spacing: 0) {
            if UIDevice.current.userInterfaceIdiom == .phone || hSizeClass == .compact {
                compactBody
                    .background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
            } else {
                fullBody
                    .background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
            }
        }
        .navigationTitle(model.title ?? model.content.builder.title)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .mirroring($model)
#endif
        .toolbar {
            ToolbarItem(id: "buildControls", placement: .primaryAction) {
                toolbarItems
            }
        }
        .sheet(isPresented: $showingPrintSetup, content: {
            NavigationStack {
                if let image = model.image(for: 512) {
                    PrintView(printing: image)
                } else {
                    ErrorView(errorDescription: "Unable to setup printing panel.")
                        .presentationDetents([.medium])
                }
            }
#if os(macOS)
            .frame(width: 500, height: 350)
#endif
        })
        .userActivity(Constants.builderHandoffActivity, element: model) { model, activity in
            if let designData = try? model.design.asData(),
               let contentData = try? model.content.asData()
            {
                activity.addUserInfoEntries(from: ["design" : designData,
                                                   "content" : contentData])
            }
        }
        .focusedSceneValue(\.qrModel, $model)
        .focusedSceneValue(\.printing, $showingPrintSetup)
        .focusedSceneValue(\.archiving, $isNamingArchivedModel)
        .onChange(of: model) { _ in
            hasMadeChanges = true
        }
        .task {
            if model.id != nil {
                self.entity = try? Persistence.shared.getQREntityWithUUID(model.id)
            }
        }
    }
}

// MARK: - Compact Style

extension BuilderView {
    
    var compactBody: some View {
        let layout = vSizeClass == .regular ? AnyLayout(VStackLayout(alignment: .center, spacing: 0)) : AnyLayout(HStackLayout(alignment: .top, spacing: 0))
        
        return layout {
            QRCodeView(qrcode: $model, interactivity: .edit)
                .equatable()
                .padding()
            
            PagerTabStripView(selection: $currentPagerTab, content: {
                
                ScrollView {
                    formView
                        .padding()
                }
                .pagerTabItem(tag: "form") {
                    Text("Content")
                        .foregroundColor(currentPagerTab == "form" ? .primary : .secondary)
                        .bold(currentPagerTab == "form")
                }
                
                ScrollView {
                    TemplateCarousel(model: $model.design)
                    DesignView(model: $model.design)
                        .padding()
                }
                .pagerTabItem(tag: "design", {
                    Text("Design")
                        .foregroundColor(currentPagerTab == "design" ? .primary : .secondary)
                        .bold(currentPagerTab == "design")
                })
            })
            .pagerTabStripViewStyle(
                .barButton(
                    tabItemSpacing: 15,
                    tabItemHeight: 50,
                    indicatorView: {
                        Rectangle()
                            .fill(Color.accentColor)
                            .cornerRadius(5)
                    })
            )
        }
    }
}

// MARK: - Full Style

extension BuilderView {
    
    var fullBody: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    QRCodeView(qrcode: $model, interactivity: .edit)
                        .equatable()
                        .padding()
                        .frame(maxHeight: 400)
                    Divider()
                    ScrollView {
                        formView
                            .padding()
                    }
                }
                
#if os(macOS)
                .frame(minWidth: 275)
#endif
#if os(iOS)
                Divider()
                ScrollView {
                    TemplateCarousel(model: $model.design)
                    Divider()
                        .padding(.vertical)
                    DesignView(model: $model.design, groupExpanded: [true, true, true])
                        .padding([.horizontal, .bottom])
                }
                .toolbarBackground(.visible, for: .navigationBar)
#else
                Divider()
                    .onHover { isHovering in
                        if isHovering {
                            NSCursor.resizeLeftRight.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    .onChange(of: geo.size.width) { width in
                        let maxWidth = width-275
                        Task { @MainActor in
                            if designPanelWidth > maxWidth {
                                designPanelWidth = maxWidth
                            } else if designPanelWidth < 275 {
                                designPanelWidth = 275
                            }
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let maxWidth = geo.size.width-275
                                let newWidth = designPanelWidth-value.translation.width
                                DispatchQueue.main.async {
                                    if 275...maxWidth ~= newWidth {
                                        designPanelWidth = newWidth
                                    }
                                }
                            }
                    )
                VStack(spacing: 0) {
                    TemplateCarousel(model: $model.design)
                        .padding(.bottom)
                        .padding(.top, 6)
                    Divider()
                    Form {
                        DesignView(model: $model.design)
                    }
                    .formStyle(.grouped)
                }
                .frame(width: designPanelWidth)
#endif
            }
        }
    }
}

// MARK: - Toolbar Items

extension BuilderView {
    
    var toolbarItems: some View {
        Menu(content: {
            Group {
                if let sharedImage = model.image(for: 128) {
                    ShareLink(item: model,
                              preview: SharePreview(
                                model.title ?? "QR Code",
                                image: sharedImage)
                    )
                }
                
#if os(iOS)
                Menu(content: {
                    ImageButton("Photos App", systemImage: "photo", action: {
                        do {
                            try model.addToPhotoLibrary(for: 512)
                            sceneModel.toaster = .saved(note: "Image saved")
                        } catch {
                            Logger.logView.error("BuilderView: Could not write QR code to photos app.")
                            sceneModel.toaster = .error(note: "Could not save photo")
                        }
                    })
                    
                    ImageButton("Files App", systemImage: "folder", action: {
                        do {
                            let data = try model.pngData(for: 512)
                            sceneModel.exportData(data, type: .png, named: "QR Code")
                        } catch {
                            Logger.logView.error("BuilderView: Could not create PNG data for QR code.")
                            sceneModel.toaster = .error(note: "Could not save file")
                        }
                    })
                    
                }, label: {
                    Label("Save Image to...", systemImage: "square.and.arrow.down")
                })
#else
                ImageButton("Save Image...", systemImage: "square.and.arrow.down", action: {
                    do {
                        let data = try model.pngData(for: 512)
                        sceneModel.exportData(data, type: .png, named: model.title ?? "QR Code")
                    } catch let error {
                        Logger.logView.error("BuilderView: Could not create PNG data for QR code.")
                        sceneModel.toaster = .error(note: "Could not save file")
                    }
                })
#endif
                
                ImageButton("Copy Image", systemImage: "doc.on.clipboard", action: {
                    model.addToPasteboard(for: 512)
                    sceneModel.toaster = .copied(note: "Image copied")
                })
            }
            
            Group {
                Divider()
                
                if entity == nil {
                    ImageButton("Add to Archive", systemImage: "archivebox", action: {
                        isNamingArchivedModel = true
                    })
                    .disabled(!hasMadeChanges)
                } else {
                    ImageButton("Save Changes", systemImage: "archivebox", action: {
                        do {
                            entity?.builder = try model.content.asData()
                            entity?.design = try model.design.asData()
                            entity?.logo = model.design.logo
                            try moc.atomicSave()

                            hasMadeChanges = false
                            sceneModel.toaster = .saved(note: "Change saved")
                        } catch {
                            Logger.logView.error("BuilderView: Could not save changes to entity in BuilderView.")
                            sceneModel.toaster = .error(note: "Changes not saved")
                        }
                    })
                    .disabled(!hasMadeChanges)
                    
                    RenameButton()
                }
            }
            
            Group {
                Divider()
                
                ImageButton("Save as PDF", image: "pdf", action: {
                    do {
                        let data = try model.pdfData()
                        sceneModel.exportData(data, type: .pdf, named: model.title ?? "QR Code")
                    } catch {
                        Logger.logView.error("BuilderView: Could not create PDF data for QR code.")
                        sceneModel.toaster = .error(note: "Could not save file")
                    }
                })
                
                ImageButton("Save as SVG", image: "svg", action: {
                    do {
                        let data = try model.svgData()
                        sceneModel.exportData(data, type: .svg, named: model.title ?? "QR Code")
                    } catch {
                        Logger.logView.error("BuilderView: Could not create SVG data for QR code.")
                        sceneModel.toaster = .error(note: "Could not save file")
                    }
                })
                
                ImageButton("Print", systemImage: "printer", action: {
                    showingPrintSetup = true
                })
            }
            
            Group {
                Divider()
                
                ImageButton("Reset", systemImage: "trash", role: .destructive, action: {
                    model.reset()
                })
            }
        }, label: {
            Label("Menu", systemImage: "ellipsis.circle")
        })
        .renameAction {
            newArchiveTitle = model.title ?? "My QR Code"
            isNamingArchivedModel = true
        }
        .alert((Text(entity == nil ? "Add to Archive" : "Rename")),
               isPresented: $isNamingArchivedModel,
               actions: {
            TextField("Title", text: $newArchiveTitle, prompt: Text("My QR Code"))
            Button("Cancel", role: .cancel, action: { isNamingArchivedModel = false })
            Button("Save", action: {
                model.title = newArchiveTitle.isEmpty ? "My QR Code" : newArchiveTitle
                do {
                    if entity == nil {
                        entity = try model.placeInCoreDataAndSave(context: moc)
                        sceneModel.toaster = .custom(
                            image: Image(systemName: "archivebox.fill"),
                            imageColor: .secondary,
                            title: "Saved",
                            note: "Code added to archive")
                    } else {
                        entity?.title = newArchiveTitle.isEmpty ? "My QR Code" : newArchiveTitle
                        try moc.atomicSave()
                    }
                } catch {
                    Logger.logView.error("BuilderView: Could not rename Core Data Entity.")
                    sceneModel.toaster = .error(note: "Could not save")
                }
            })
        })
    }
}

struct BuilderView_Previews: PreviewProvider {
    static var previews: some View {
        BuilderView()
            .environmentObject(SceneModel())
            .environment(\.managedObjectContext, Persistence.shared.container.viewContext)
    }
}

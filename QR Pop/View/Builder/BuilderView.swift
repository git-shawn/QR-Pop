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
    @State private var viewingRawData: Bool = false
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.verticalSizeClass) var vSizeClass
    @Environment(\.managedObjectContext) var moc
    
    @AppStorage("imageExportQuality", store: .appGroup) var imageExportQuality: Int = 512
    @AppStorage("exportsAttempted", store: .appGroup) var exportsAttempted: Int = 0
    @Environment(\.requestReview) var requestReview
    
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
                
                Menu(content: {
#if os(iOS)
                    ImageButton("Image to Photos", systemImage: "photo", action: {
                        do {
                            try model.addToPhotoLibrary(for: imageExportQuality)
                            sceneModel.toaster = .saved(note: "Image saved")
                            sceneModel.toaster = .saved(note: "Image saved")
                            noteSuccessfulExport()
                        } catch {
                            Logger.logView.error("BuilderView: Could not write QR code to photos app.")
                            sceneModel.toaster = .error(note: "Could not save photo")
                        }
                    })
#endif
                    
                    ImageButton("Image\(" to Files", platforms: [.iOS])", systemImage: "folder", action: {
                        do {
                            let data = try model.pngData(for: 512)
                            sceneModel.exportData(data, type: .png, named: "QR Code")
                        } catch {
                            Logger.logView.error("BuilderView: Could not create PNG data for QR code.")
                            sceneModel.toaster = .error(note: "Could not save file")
                        }
                    })
                    
                    MenuControlGroupConvertible {
                        ImageButton("PDF\(" to Files", platforms: [.iOS])", image: "pdf", action: {
                            do {
                                let data = try model.pdfData()
                                sceneModel.exportData(data, type: .pdf, named: model.title ?? "QR Code")
                            } catch {
                                Logger.logView.error("BuilderView: Could not create PDF data for QR code.")
                                sceneModel.toaster = .error(note: "Could not save file")
                            }
                        })
                        
                        ImageButton("SVG\(" to Files", platforms: [.iOS])", image: "svg", action: {
                            do {
                                let data = try model.svgData()
                                sceneModel.exportData(data, type: .svg, named: model.title ?? "QR Code")
                            } catch {
                                Logger.logView.error("BuilderView: Could not create SVG data for QR code.")
                                sceneModel.toaster = .error(note: "Could not save file")
                            }
                        })
                    }
                    
                }, label: {
                    Label("Save...", systemImage: "square.and.arrow.down")
                })
                
                ImageButton("Copy Image", systemImage: "doc.on.doc", action: {
                    model.addToPasteboard(for: imageExportQuality)
                    sceneModel.toaster = .copied(note: "Image copied")
                })
                
                Picker("Image Quality", systemImage: "sparkle.magnifyingglass", selection: $imageExportQuality, content: {
                    Group {
                        Text("Low").tag(256)
                        Text("Medium").tag(512)
                        Text("High").tag(1024)
                        Text("4K").tag(3840)
                    }
                })
                .pickerStyle(.menu)
                
                ImageButton("Print", systemImage: "printer", action: {
                    showingPrintSetup = true
                })
            }
            
            Group {
                Divider()
                
                if entity == nil {
                    ImageButton("Add to Archive", systemImage: "archivebox", action: {
                        isNamingArchivedModel = true
                    })
                } else {
                    ImageButton("Save Changes", systemImage: "archivebox", action: {
                        do {
                            entity?.builder = try model.content.asData()
                            entity?.design = try model.design.asData()
                            entity?.logo = model.design.logo
                            try moc.atomicSave()
                            sceneModel.toaster = .saved(note: "Change saved")
                        } catch {
                            Logger.logView.error("BuilderView: Could not save changes to entity in BuilderView.")
                            sceneModel.toaster = .error(note: "Changes not saved")
                        }
                    })
                    
                    RenameButton()
                }
            }
            
            Group {
                Divider()
                ImageButton(
                    "View Raw Data",
                    systemImage: "doc.text.magnifyingglass",
                    action: {
                        viewingRawData = true
                    })
                .disabled(model.content.result.isEmpty)
                
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
        .sheet(isPresented: $viewingRawData, content: {
            RawDataView(data: model.content.result)
#if os(macOS)
                .frame(width: 400, height: 450)
#else
                .presentationDetents([.medium,.large])
                .presentationDragIndicator(.visible)
#endif
        })
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
                        noteSuccessfulExport()
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
    
    func noteSuccessfulExport() {
        if exportsAttempted < 5 {
            exportsAttempted += 1;
        } else if exportsAttempted == 5 {
            requestReview()
        }
    }
}

struct BuilderView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BuilderView()
                .environmentObject(SceneModel())
                .environment(\.managedObjectContext, Persistence.shared.container.viewContext)
        }
    }
}

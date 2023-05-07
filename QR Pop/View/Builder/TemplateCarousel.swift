//
//  TemplateCarousel.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI
import CoreData
import OSLog

struct TemplateCarousel: View {
    @FetchRequest private var templates: FetchedResults<TemplateEntity>
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var sceneModel: SceneModel
    @Binding var designModel: DesignModel
    
    @State private var savingTemplate = false
    @State private var templateTitle = ""
    @State private var viewingAllTemplates = false
    @State private var isRenaming: Bool = false
    @State private var entityToRename: TemplateEntity? = nil
    
    init(model: Binding<DesignModel>) {
        self._designModel = model
        
        let request: NSFetchRequest<TemplateEntity> = TemplateEntity.fetchRequest()
        
        request.sortDescriptors = [
            NSSortDescriptor(key: "created", ascending: false)
        ]
        
        _templates = FetchRequest(fetchRequest: request)
    }
}

// MARK: - Define the View

extension TemplateCarousel {
    
    var body: some View {
        CarouselView {
            
            addTemplateButton
            
            ForEach(templates.prefix(5)) { template in
                if let model = try? template.asModel() {
                    Button(action: {
                        assignTemplate(model: model, template: template)
                    }, label: {
                        buildButtonView(model: model, template: template)
                    })
                    .buttonStyle(.plain)
                }
            }
            
            if templates.count >= 5 {
                allTemplatesButton
            }
        }
        .animation(.spring(), value: templates)
        .sheet(isPresented: $viewingAllTemplates) {
            allTempaltesSheet
#if os(macOS)
                .frame(minWidth: 450, minHeight: 400)
#endif
        }
    }
}

// MARK: - Carousel Button View

extension TemplateCarousel {
    
    @ViewBuilder
    func buildButtonView(model: TemplateModel, template: TemplateEntity) -> some View {
        VStack {
            QRCodeView(
                design: .constant(model.design),
                builder: .constant(BuilderModel())
            )
#if os(iOS)
            .hoverEffect(.lift)
#endif
            .frame(width: 64, height: 64)
            .background(
            RoundedRectangle(cornerRadius: 10)
                .shadow(radius: 4)
                .padding(1)
            )
            .contextMenu {
                buildContextMenu(model: model, entity: template)
            }
            .padding(.top)
            
            Text(model.title)
                .lineLimit(1)
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 72)
        }
        .alert("Rename", isPresented: $isRenaming, actions: {
            TextField("My Template", text: $templateTitle)
            Button("Cancel", role: .cancel, action: {
                isRenaming = false
            })
            Button("Save", action: {
                do {
                    entityToRename?.title = templateTitle
                    templateTitle = ""
                    entityToRename = nil
                    try moc.atomicSave()
                } catch {
                    Logger.logView.error("TemplateCarousel: Could not rename Template.")
                }
            })
            .disabled(templateTitle.isEmpty)
        })
    }
}

// MARK: - Add Template Button

extension TemplateCarousel {
    
    var addTemplateButton: some View {
        VStack {
            Button(action: {
                savingTemplate.toggle()
            }, label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.hierarchical)
            })
            .buttonStyle(.plain)
#if os(iOS)
            .hoverEffect(.lift)
#else
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient.macAccentStyle.opacity(0.25),
                        lineWidth: 1)
            )
#endif
            .padding(6)
            .foregroundStyle(.secondary)
            .frame(width: 64, height: 64)
            .padding(.top)
            
            Text("Add Template")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(width: 72)
        }
        .padding(.leading)
        .alert("New Template", isPresented: $savingTemplate, actions: {
            TextField("Title", text: $templateTitle, prompt: Text("My Template"))
            Button("Cancel", role: .cancel, action: {})
            Button("Save", action: {
                do {
                    try designModel.createTemplate(named: templateTitle, in: moc)
                    templateTitle = ""
                } catch {
                    Logger.logView.error("TemplateCarousel: A template could not be created from the model.")
                    sceneModel.toaster = .error(note: "Template could not be saved")
                }
            })
        }, message: {
            Text("Save your current design as a new template.")
        })
    }
}

// MARK: - All Templates Button

extension TemplateCarousel {
    
    var allTemplatesButton: some View {
        VStack {
            Button(action: {
                viewingAllTemplates = true
            }, label: {
                Image(systemName: "ellipsis.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.hierarchical)
            })
            .buttonStyle(.plain)
#if os(iOS)
            .hoverEffect(.lift)
#else
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient.macAccentStyle.opacity(0.25),
                        lineWidth: 1)
            )
#endif
            .padding(6)
            .foregroundStyle(.secondary)
            .frame(width: 64, height: 64)
            .padding(.top)
            
            Text("All Template")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(width: 72)
        }
    }
}

// MARK: - All Templates Sheet

extension TemplateCarousel {
    
    var allTempaltesSheet: some View {
        NavigationStack {
            CoreDataList<TemplateEntity>(
                entityType: .template,
                fetchedItems: Array(templates),
                selectAction: { template in
                    guard let design = template.design,
                          let designModel = try? DesignModel(decoding: design, with: template.logo)
                    else { return }
                    self.designModel = designModel
                    viewingAllTemplates = false
                })
            .navigationTitle("All Templates")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: {
                        viewingAllTemplates = false
                    })
                }
            }
        }
    }
}

// MARK: - Context Menu

extension TemplateCarousel {
    
    @ViewBuilder
    func buildContextMenu(model: TemplateModel, entity: TemplateEntity) -> some View {
        Group {
            ImageButton("Rename", systemImage: "pencil", action: {
                templateTitle = entity.title ?? "My Template"
                entityToRename = entity
                isRenaming = true
            })
            
            #if os(iOS)
            
            ShareLink("Share Template",
                      item: model,
                      preview: SharePreview(
                        model.title,
                        image: model.preview(for: 144) ?? Image(systemName: "qrcode")
                      )
            )
            #else
            Button("Save Template", action: {
                if let data = model.asData() {
                    sceneModel.exporter = .init(document: DataFileDocument(initialData: data), UTType: .qrpt, defaultName: model.title)
                }
            })
            #endif
            
            Divider()
            
            ImageButton("Delete Template", systemImage: "trash", role: .destructive, action: {
                do {
                    moc.delete(entity)
                    try moc.atomicSave()
                } catch {
                    Logger.logView.error("TemplateCarousel: A template could not be removed from the database.")
                    sceneModel.toaster = .error(note: "Template could not be deleted")
                }
            })
        }
    }
}

// MARK: - View Functions

extension TemplateCarousel {
    
    /// Assign the chosen template to the bound ``DesignModel``.
    func assignTemplate(model: TemplateModel, template: TemplateEntity) {
        self.designModel = model.design
    }
}

struct TemplateCarousel_Previews: PreviewProvider {
    static var previews: some View {
        TemplateCarousel(model: .constant(DesignModel()))
            .background(Color.groupedBackground)
            .environment(\.managedObjectContext, Persistence.shared.container.viewContext)
    }
}

//
//  ArchiveView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI
import AppIntents
import OSLog

struct ArchiveView: View {
    var model: QRModel
    @State private var isFullscreen: Bool = false
    @Environment(\.openWindow) var openWindow
    @EnvironmentObject var sceneModel: SceneModel
    @EnvironmentObject var navigationModel: NavigationModel
    @AppStorage("showSiriTips", store: .appGroup) var showArchiveSiriTip: Bool = true
    
    var body: some View {
        ZStack(alignment: .center) {
            QRCodeView(qrcode: .constant(model), interactivity: .share)
                .equatable()
                .zIndex(1)
                .id("code")
                .padding()
                .drawingGroup()
            if isFullscreen {
                VStack {
                    HStack {
                        Spacer()
                        ImageButton("Toggle Fullscreen", systemImage: "arrow.down.right.and.arrow.up.left.circle.fill", action: {
                            isFullscreen = false
                        })
                        .zIndex(2)
                        .foregroundColor(model.design.backgroundColor)
                        .font(.largeTitle)
                        .symbolRenderingMode(.hierarchical)
                        .labelStyle(.iconOnly)
                        .padding()
                    }
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(isFullscreen ? model.design.pixelColor : Color.groupedBackground, ignoresSafeAreaEdges: .all)
#if os(iOS)
        .statusBarHidden(isFullscreen)
        .animation(.easeIn, value: isFullscreen)
        .toolbar(isFullscreen ? .hidden : .visible, for: .navigationBar, .tabBar, .bottomBar)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .top) {
            if !isFullscreen && showArchiveSiriTip {
                HStack {
                    SiriTipView(
                        intent: ViewArchiveIntent(),
                        isVisible: $showArchiveSiriTip)
                }
                .scenePadding()
                .background(.ultraThinMaterial)
                .transition(.move(edge: .top))
            }
        }
        .task {
            IntentDonationManager.shared.donate(intent: ViewArchiveIntent(for: model))
        }
        .mirroring(.constant(model))
#endif
        .navigationTitle(model.title ?? "QR Code")
        .animation(.default, value: isFullscreen)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu(content: {
                    
                    // Export functions
                    Group {
                        ShareLink(item: model, preview: SharePreview(model.title ?? "QR Code", image: model))
                        
                        Menu(content: {
#if os(iOS)
                            ImageButton("Image to Photos", systemImage: "photo", action: {
                                do {
                                    try model.addToPhotoLibrary(for: 512)
                                    sceneModel.toaster = .saved(note: "Image saved")
                                } catch {
                                    Logger.logView.error("ArchiveView: Could not write QR code to photos app.")
                                    sceneModel.toaster = .error(note: "Could not save photo")
                                }
                            })
#endif
                            
                            ImageButton("Image\(" to Files", platforms: [.iOS])", systemImage: "folder", action: {
                                do {
                                    let data = try model.pngData(for: 512)
                                    sceneModel.exportData(data, type: .png, named: "QR Code")
                                } catch {
                                    Logger.logView.error("ArchiveView: Could not create PNG data for QR code.")
                                    sceneModel.toaster = .error(note: "Could not save file")
                                }
                            })
                            
                            MenuControlGroupConvertible {
                                ImageButton("PDF\(" to Files", platforms: [.iOS])", image: "pdf", action: {
                                    do {
                                        let data = try model.pdfData()
                                        sceneModel.exportData(data, type: .pdf, named: model.title ?? "QR Code")
                                    } catch {
                                        Logger.logView.error("ArchiveView: Could not create PDF data for QR code.")
                                        sceneModel.toaster = .error(note: "Could not save file")
                                    }
                                })
                                
                                ImageButton("SVG\(" to Files", platforms: [.iOS])", image: "svg", action: {
                                    do {
                                        let data = try model.svgData()
                                        sceneModel.exportData(data, type: .svg, named: model.title ?? "QR Code")
                                    } catch {
                                        Logger.logView.error("ArchiveView: Could not create SVG data for QR code.")
                                        sceneModel.toaster = .error(note: "Could not save file")
                                    }
                                })
                            }
                            
                        }, label: {
                            Label("Save...", systemImage: "square.and.arrow.down")
                        })
                        
                        ImageButton("Copy Image", systemImage: "doc.on.doc", action: {
                            model.addToPasteboard(for: 512)
                            sceneModel.toaster = .copied(note: "Image copied")
                        })
                        
                        ImageButton("Print", systemImage: "printer", action: {
#warning("Printing not implemented")
                        })
                        .disabled(true)
                    }
                    
                    // Archive functions
                    Group {
                        Divider()
                        
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            ImageButton("Create Notification", systemImage: "bell") {
                                // This button should be changed to "modify notification" if a notification exists.
                                // The status of whether or not a notification exists should be saved to AppStorage, not CoreData.
#warning("Location notify not implemented")
                                print("notify location")
                            }
                            .disabled(true)
                        }
                        
                        ImageButton("Change Symbol", systemImage: "rays") {
                            // Change the symbol that appears on most widgets.
                            // Can be either an SF symbol or two uppercase characters/numbers.
                            // This may need to be saved to CloudKit.
#warning("Custom widget symbol not implemented")
                        }
                        .disabled(true)
                        
                        ImageButton("Edit Code", systemImage: "slider.horizontal.3") {
                            withAnimation {
                                navigationModel.navigateWithoutBack(to: .builder(code: model))
                            }
                        }
                    }
                    
                    // Destructive functions
                    Group {
                        Divider()
                        
                        ImageButton("Rename", systemImage: "pencil") {
#warning("Rename not implemented")
                            print("rename code")
                        }
                        .disabled(true)
                        
                        ImageButton("Delete", systemImage: "trash", role: .destructive) {
#warning("Delete not implemented")
                            print("rename code")
                        }
                        .disabled(true)
                    }
                }, label: {
                    Label("Options", systemImage: "ellipsis.circle")
                })
            }
            
            ToolbarItem(placement: .primaryAction) {
                ImageButton("View Fullscreen", systemImage: "arrow.up.backward.and.arrow.down.forward") {
#if os(iOS)
                    DispatchQueue.main.async {
                        isFullscreen = true
                    }
#else
                    openWindow(id: "codePresentation", value: model)
#endif
                }
            }
        }
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ArchiveView(model: QRModel())
                .environmentObject(SceneModel())
        }
    }
}

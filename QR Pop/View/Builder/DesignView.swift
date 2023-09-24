//
//  DesignView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/10/23.
//

import SwiftUI
import PhotosUI
import QRCode
import OSLog

struct DesignView: View {
    @Binding var model: DesignModel
    @EnvironmentObject var sceneModel: SceneModel
    @State private var matchEyesPupils: Bool = false
    @State var groupExpanded: [Bool] = [false, false, false]
    @State private var photoPicked: PhotosPickerItem? = nil
    @State private var pickingFromPhotos: Bool = false
    @State private var pickingFromFiles: Bool = false
    
    var body: some View {
#if os(iOS)
        VStack(spacing: 20) {
            DisclosureGroup("Pixels", isExpanded: $groupExpanded[0]) {
                pixels
            }
            .disclosureGroupStyle(SpringyDisclosureStyle())
            
            DisclosureGroup("Eyes", isExpanded: $groupExpanded[1]) {
                eyes
            }
            .disclosureGroupStyle(SpringyDisclosureStyle())
            
            DisclosureGroup("Background", isExpanded: $groupExpanded[2]) {
                background
            }
            .disclosureGroupStyle(SpringyDisclosureStyle())
            
            photoPicker
        }
#else
        Group {
            Section("Pixels") {
                pixels
            }
            
            Section("Eyes") {
                eyes
            }
            
            Section("Background") {
                background
            }
            
            Section("Photo Overlay") {
                photoPicker
            }
        }
#endif
    }
}

// MARK: - Pixel Panel

extension DesignView {
    
    var pixels: some View {
        VStack(spacing: 20) {
            
            ColorPicker(
                "Pixel Color",
                selection: $model.pixelColor,
                supportsOpacity: false)
            
            HStack {
                Text("Pixel Shape")
                
                Spacer()
                
                Menu(content: {
                    ForEach(DesignModel.PixelShape.allCases, id: \.rawValue ) { shape in
                        Button(action: {
                            model.pixelShape = shape
                        }, label: {
                            Label(title: {
                                Text(shape.title)
                            }, icon: {
                                shape.symbol
                            })
                            .labelStyle(.titleAndIcon)
                        })
                    }
                }, label: {
                    Label(title: {
                        Text(model.pixelShape.title)
                    }, icon: {
                        model.pixelShape.symbol
                    })
                })
                .scaledToFit()
                .menuOrder(.fixed)
            }
            
            HStack {
                Text("Error Correction")
                
                Spacer()
                
                Menu(content: {
                    Button("Low", action: {model.errorCorrection = .low})
                    Button("Medium", action: {model.errorCorrection = .medium})
                    Button("High", action: {model.errorCorrection = .high})
                }, label: {
                    switch model.errorCorrection {
                    case .low: Text("Low")
                    case .medium: Text("Medium")
                    case .high: Text("High")
                    case .quantize: Text("Quantize")
                    }
                })
                .scaledToFit()
                .menuOrder(.fixed)
            }
        }
    }
}

// MARK: - Eye Panel

extension DesignView {
    
    var eyes: some View {
        VStack(spacing: 20) {
            
            ColorPicker(
                "Eye Color",
                selection: $model.eyeColor,
                supportsOpacity: false)
            .onChange(of: model.eyeColor) { color in
                if matchEyesPupils {
                    model.pupilColor = color
                }
            }
            
            ColorPicker(
                "Pupil Color",
                selection: $model.pupilColor,
                supportsOpacity: false)
            .disabled(matchEyesPupils)
            .opacity(matchEyesPupils ? 0.5 : 1)
            
            Toggle("Match Pupils with Eyes", isOn: $matchEyesPupils)
                .onChange(of: matchEyesPupils) { bool in
                    if bool {
                        model.pupilColor = model.eyeColor
                    }
                }
            
            HStack {
                Text("Eye Shape")
                
                Spacer()
                
                Menu(content: {
                    ForEach(DesignModel.EyeShape.allCases, id: \.rawValue ) { shape in
                        Button(action: {
                            model.eyeShape = shape
                        }, label: {
                            Label(title: {
                                Text(shape.title)
                            }, icon: {
                                shape.symbol
                            })
                            .labelStyle(.titleAndIcon)
                        })
                    }
                }, label: {
                    Label(title: {
                        Text(model.eyeShape.title)
                    }, icon: {
                        model.eyeShape.symbol
                    })
                })
                .scaledToFit()
                .menuOrder(.fixed)
            }
        }
    }
}

// MARK: - Background Panel

extension DesignView {
    
    var background: some View {
        VStack(spacing: 20) {
            ColorPicker("Background Color", selection: $model.backgroundColor)
            
            HStack {
                Text("Background Accent")
                
                Spacer()
                
                Menu(content: {
                    Button("None", action: {model.offPixels = nil})
                    ImageButton("Columns", image: "dataVertical", action: {
                        model.offPixels = .vertical
                    })
                    ImageButton("Rows", image: "dataHorizontal", action: {
                        model.offPixels = .horizontal
                    })
                    ImageButton("Dots", image: "dataCircle", action: {
                        model.offPixels = .circle
                    })
                }, label: {
                    switch model.offPixels {
                    case .none: Text("None")
                    default:
                        Label(title: {
                            Text(model.offPixels?.title ?? "Error")
                        }, icon: {
                            model.offPixels?.symbol ?? Image(systemName: "exclamationmark.triangle")
                        })
                    }
                })
                .scaledToFit()
                .menuOrder(.fixed)
            }
        }
    }
}

// MARK: - Photo Picker

extension DesignView {
    
    var photoPicker: some View {
        
        VStack(spacing: 20) {
            
            Menu(content: {
                ImageButton("Photos App", systemImage: "photo", action: {
                    pickingFromPhotos = true
                })
                
                Button(action: {
                    pickingFromFiles = true
                }, label: {
#if os(macOS)
                    Text("Finder")
#else
                    Label("Files App", systemImage: "folder")
#endif
                })
            }, label: {
                HStack {
                    Label((model.logo == nil ) ? "Add Image" : "Change Image",
                          systemImage: "photo.badge.plus")
                    .symbolRenderingMode(.hierarchical)
                    .padding(10)
                    .frame(maxWidth: .infinity)
#if os(iOS)
                    Spacer()
                    Divider()
                        .overlay(Color.accentColor)
                    Image(systemName: "chevron.up.chevron.down")
#endif
                }
            })
            .buttonStyle(.bordered)
            .tint(.accentColor)
            .fileImporter(isPresented: $pickingFromFiles, allowedContentTypes: [UTType.image], onCompletion: { result in
                switch result {
                case .success(let success):
                    Task {
                        guard success.startAccessingSecurityScopedResource(),
                              let data = try? Data(contentsOf: success)
                        else {
                            success.stopAccessingSecurityScopedResource()
                            sceneModel.toaster = .error(note: "Could not read file")
                            return
                        }
                        success.stopAccessingSecurityScopedResource()
                        
                        try model.setLogo(data)
                    }
                case .failure(_):
                    Logger.logView.error("DesignView: Could not import file.")
                    sceneModel.toaster = .error(note: "Could not import file")
                }
            })
            .photosPicker(isPresented: $pickingFromPhotos,
                          selection: $photoPicked,
                          matching: .any(of: [.images, .not(.livePhotos)]),
                          preferredItemEncoding: .compatible
            )
            .onChange(of: photoPicked) { photo in
                Task {
                    guard let photo = photo,
                          let data = try? await photo.loadTransferable(type: Data.self)
                    else { return }
                    
                    try model.setLogo(data)
                }
            }
            
            if model.logo != nil {
                ControlGroup {
#if os(iOS)
                    Spacer()
#endif
                    
                    Button(role: .destructive, action: {
                        withAnimation(.spring()) {
                            photoPicked = nil
                        }
                        model.logo = nil
                    }, label: {
                        Label("Delete", systemImage: "trash")
                    })
                    .padding()
                    .background(
                        Circle()
                            .fill(.red)
                            .opacity(0.15)
                    )
                    
#if os(iOS)
                    Spacer()
#endif
                    
                    ImageButton("Counter-Clockwise", systemImage: "arrow.counterclockwise", action: {
                        model.rotateLogo(direction: .counterclockwise)
                    })
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.gray)
                            .opacity(0.15)
                    )
                    
#if os(iOS)
                    Spacer()
#endif
                    
                    ImageButton("Clockwise", systemImage: "arrow.clockwise", action: {
                        model.rotateLogo(direction: .clockwise)
                    })
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.gray)
                            .opacity(0.15)
                    )
                    
#if os(iOS)
                    Spacer()
#endif
                    
                    Menu(content: {
                        Text("Image Placement")
                        
                        Divider()
                        
                        Button(action: {
                            model.logoPlacement = .center
                        }, label: {
                            HStack {
                                Text("Center")
                                if model.logoPlacement == .center {
                                    Image(systemName: "checkmark")
                                }
                            }
                        })
                        
                        Button(action: {
                            model.logoPlacement = .bottomTrailing
                        }, label: {
                            HStack {
                                Text("Bottom Trailing")
                                if model.logoPlacement == .bottomTrailing {
                                    Image(systemName: "checkmark")
                                }
                            }
                        })
                        
                    }, label: {
                        Label("Place Image", systemImage: "arrow.up.and.down.and.arrow.left.and.right")
                    })
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.accentColor)
                            .opacity(0.15)
                    )
                    
#if os(iOS)
                    Spacer()
#endif
                }
                
                .labelStyle(.iconOnly)
                .symbolRenderingMode(.hierarchical)
                .buttonStyle(.borderless)
#if os(iOS)
                .controlGroupStyle(.navigation)
#endif
            }
        }
    }
}

struct DesignView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            DesignView(model: .constant(DesignModel()))
                .padding()
        }
        .background(Color.groupedBackground)
    }
}

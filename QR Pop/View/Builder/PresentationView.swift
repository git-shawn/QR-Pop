//
//  PresentationView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/15/23.
//

import SwiftUI

struct PresentationView: View {
    @ObservedObject var model = MirrorModel.shared
    @AppStorage("enhancedMirroringEnabled", store: .appGroup) private var enhancedMirroringEnabled: Bool = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Group {
            if let presentedModel = model.presentedModel, model.isMirroring {
                GeometryReader { proxy in
                    let minProxySize = min(proxy.size.width, proxy.size.height)
                    HStack(spacing: proxy.size.width*0.025) {
                        Spacer()
                        
                        QRCodeView(qrcode: .constant(presentedModel), interactivity: .view)
                            .equatable()
                            .padding()
                            .drawingGroup()
                        
                        if model.showModelDetails {
                            
                            RoundedRectangle(cornerRadius: minProxySize*0.05)
                                .fill(.ultraThickMaterial)
                                .frame(width: proxy.size.width*0.35, height: proxy.size.height*0.4)
                                .overlay(
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("\(presentedModel.title ?? "My QR Code")")
                                            .font(.system(size: minProxySize*0.05))
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .lineLimit(2)
                                        Text("\(presentedModel.content.builder.icon) \(presentedModel.content.builder.title) QR Code")
                                            .font(.system(size: minProxySize*0.035))
                                            .foregroundColor(.secondary)
                                    }
                                        .padding(proxy.size.width*0.03)
                                )
                            Spacer()
                        } else {
                            Spacer()
                        }
                    }
                    .transition(.move(edge: .trailing))
                    .animation(.spring(), value: model.showModelDetails)
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(presentedModel.design.backgroundColor, ignoresSafeAreaEdges: .all)
                }
            } else {
                VStack(spacing: 20) {
                    Image("LaunchIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
#if os(macOS)
                        .onAppear {
                            model.isMirroring = false
                            dismiss()
                        }
#endif
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black, ignoresSafeAreaEdges: .all)
            }
        }
        .transition(.opacity)
        .animation(.default, value: model.presentedModel)
        .preferredColorScheme(.dark)
    }
}

// MARK: - MacOS Commands

#if os(macOS)

struct PresentationCommands: Commands {
    @ObservedObject private var model = MirrorModel.shared
    @Environment(\.openWindow) var openWindow
    
    var body: some Commands {
        CommandGroup(after: .windowArrangement, addition: {
            Button("View Code in New Window", action: {
                model.isMirroring = true
                openWindow(id: "presentationWindow")
            })
            .disabled(model.presentedModel == nil)
            .keyboardShortcut("w", modifiers: [.control,.command])
            
            Toggle("Show Details", isOn: $model.showModelDetails)
                .disabled(!model.isMirroring)
        })
    }
}

#endif

// MARK: - View Modifier

struct PresentationViewModifier: ViewModifier {
    @AppStorage("enhancedMirroringEnabled", store: .appGroup) private var enhancedMirroringEnabled: Bool = true
    @ObservedObject var model = MirrorModel.shared
    @Binding var presenting: QRModel
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                model.presentedModel = presenting
            }
            .onChange(of: presenting, debounce: 1) { qrModel in
                model.presentedModel = qrModel
            }
            .onDisappear {
                model.presentedModel = nil
            }
#if os(iOS)
            .toolbar {
                if model.isMirroring {
                    ToolbarItemGroup(placement: .bottomBar, content: {
                        Text("\(Image(systemName: "exclamationmark.shield")) This code is being mirrored")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                        Toggle(isOn: $model.showModelDetails, label: {
                            Label("Toggle Mirroring Details", systemImage: "tv")
                        })
                        .tint(.blue)
                    })
                    
                }
            }
#endif
    }
}

// MARK: - Mirrorable View Extension

extension View {
    func mirrorable(_ presenting: Binding<QRModel>) -> some View {
        modifier(PresentationViewModifier(presenting: presenting))
    }
}

struct PresentationView_Previews: PreviewProvider {
    static var previews: some View {
        PresentationWrapper()
    }
    
    struct PresentationWrapper: View {
        init() {
            MirrorModel.shared.presentedModel = QRModel()
            MirrorModel.shared.presentedModel?.design.backgroundColor = Color.random
            MirrorModel.shared.showModelDetails = true
        }
        var body: some View {
            PresentationView()
        }
    }
}

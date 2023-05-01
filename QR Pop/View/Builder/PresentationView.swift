//
//  PresentationView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/15/23.
//

import SwiftUI

struct PresentationView: View {
    /**
     On macOS this view is created via `openWindow`. However, on iOS and iPadOS this view is created in the background on non-interactive displays.
     Therefore, the view should be passed *explicitly* on macOS via a binding and *implicitly* via the scene's `FocusedBinding`.
     */
    @Binding var model: QRModel?
    @Environment(\.dismiss) var dismiss
#if os(iOS)
    @ObservedObject var mirrorModel = MirrorModel.shared
#endif
    
    var body: some View {
        if let model = model {
            GeometryReader { proxy in
                let minSize = min(proxy.size.width, proxy.size.height)
                HStack(spacing: proxy.size.width/40) {
                    Spacer()
                    QRCodeView(qrcode: $model.withDefault(QRModel()), interactivity: .view)
                        .equatable()
                        .padding()
                        .drawingGroup()
#if os(iOS)
                    if mirrorModel.showDetails {
                        
                        RoundedRectangle(cornerRadius: minSize/20)
                            .fill(.thickMaterial)
                            .frame(width: proxy.size.width/3, height: proxy.size.height/2.5)
                            .overlay {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(model.title ?? "QR Code")
                                        .font(.system(size: minSize/20))
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(2)
                                    Text("\(model.content.builder.icon) \(model.content.builder.title) QR Code")
                                        .font(.system(size: minSize/30))
                                        .foregroundColor(.secondary)
                                }
                                .padding(minSize/30)
                            }
                    }
#endif
                    
                    Spacer()
                }
            }
#if os(iOS)
            .transition(.move(edge: .trailing))
            .animation(.spring(), value: mirrorModel.showDetails)
#endif
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(model.design.backgroundColor, ignoresSafeAreaEdges: .all)
            .preferredColorScheme(.dark)
        } else {
            VStack(spacing: 20) {
                Image("LaunchIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black, ignoresSafeAreaEdges: .all)
            .preferredColorScheme(.dark)
        }
    }
}

#if os(iOS)
// MARK: - View Modifier

struct PresentationViewModifier: ViewModifier {
    @ObservedObject var model = MirrorModel.shared
    @Binding var presenting: QRModel
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    let mirroring = (model.presentedModel != nil)
                    
                    if model.nonInteractiveExternalDisplayIsConnected {
                        Group {
                            if mirroring {
                                if model.presentedModel == presenting {
                                    Text("\(Image(systemName: "bolt.shield")) This code is being mirrored")
                                } else {
                                    Text("\(Image(systemName: "xmark.shield")) Another code is being mirrored")
                                }
                            } else {
                                Text("\(Image(systemName: "exclamationmark.shield")) Your display is being mirrored")
                            }
                        }
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        
                        Menu(content: {
                            Button(action: {
                                model.presentedModel = presenting
                            }, label: {
                                if mirroring {
                                    Label("Refresh Code", systemImage: "sparkles.tv")
                                } else {
                                    Label("Present QR Code", systemImage: "play.tv")
                                }
                            })
                            
                            Divider()
                            
                            Button(action: {
                                model.disconnectMirroredScene()
                            }, label: {
                                Label("Stop Presenting Code", systemImage: "stop.circle")
                            })
                            .disabled(!mirroring)
                            
                            Toggle(isOn: $model.showDetails, label: {
                                Label("Toggle Details Card", systemImage: "list.bullet.rectangle")
                            })
                            .disabled(!mirroring)
                        }, label: {
                            Label("Mirroring Options", systemImage: "tv")
                        })
                        .tint(.blue)
                    }
                }
                
            }
    }
}

// MARK: - Mirrorable View Extension

extension View {
    func mirroring(_ presenting: Binding<QRModel>) -> some View {
        modifier(PresentationViewModifier(presenting: presenting))
    }
}

#endif

struct PresentationView_Previews: PreviewProvider {
    static var previews: some View {
        PresentationWrapper()
    }
    
    struct PresentationWrapper: View {
        @State var model: QRModel? = QRModel()
        
        var body: some View {
            PresentationView(model: $model)
                .previewDisplayName("CodePresentationView")
            PresentationView(model: .constant(nil))
                .previewDisplayName("Nil CodePresentationView")
        }
    }
}

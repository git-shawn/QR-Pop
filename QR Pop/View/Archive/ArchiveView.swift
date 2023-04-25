//
//  ArchiveView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI

struct ArchiveView: View {
    var model: QRModel
    @State private var isFullscreen: Bool = false
    @Environment(\.openWindow) var openWindow
    @EnvironmentObject var sceneModel: SceneModel
    @EnvironmentObject var navigationModel: NavigationModel
    
    var body: some View {
        ZStack(alignment: .center) {
            QRCodeView(qrcode: .constant(model), interactivity: .share)
                .equatable()
                .zIndex(1)
                .id("code")
                .padding()
                .drawingGroup()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(isFullscreen ? model.design.pixelColor : Color.groupedBackground, ignoresSafeAreaEdges: .all)
#if os(iOS)
        .onTapGesture {
            if isFullscreen {
                isFullscreen.toggle()
            }
        }
        .statusBarHidden(isFullscreen)
        .animation(.easeIn, value: isFullscreen)
        .toolbarBackground(.visible, for: .bottomBar, .navigationBar, .tabBar)
        .toolbar(isFullscreen ? .hidden : .visible, for: .navigationBar, .tabBar)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .mirrorable(.constant(model))
        .navigationTitle(model.title ?? "QR Code")
        .animation(.default, value: isFullscreen)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ImageButton("Edit", systemImage: "slider.horizontal.3", action: {
                    DispatchQueue.main.async {
                        withAnimation {
                            navigationModel.navigateWithoutBack(to: .builder(code: model))
                        }
                    }
                })
                NavigationLink(destination: {
                    BuilderView(model: model)
                }, label: {
                    Label("Edit", systemImage: "slider.horizontal.3")
                })
            }
            
            ToolbarItem(placement: .primaryAction) {
                ImageButton("View Fullscreen", systemImage: "arrow.up.backward.and.arrow.down.forward", action: {
#if os(iOS)
                    DispatchQueue.main.async {
                        isFullscreen = true
                        sceneModel.toaster = .custom(
                            image: Image(systemName: "arrow.down.forward.and.arrow.up.backward"),
                            imageColor: .secondary,
                            title: "Fullscreen",
                            note: "Tap anywhere to dismiss")
                    }
#else
                    MirrorModel.shared.isMirroring = true
                    openWindow(id: "presentationWindow")
#endif
                })
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

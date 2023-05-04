//
//  ArchiveView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI
import AppIntents

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
                ImageButton("Edit", systemImage: "slider.horizontal.3") {
                    withAnimation {
                        navigationModel.navigateWithoutBack(to: .builder(code: model))
                    }
                }
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

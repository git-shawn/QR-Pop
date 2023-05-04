//
//  ScannerView.swift
//  QR Pop
//
//  Created by Shawn Davis on 3/17/23.
//

import SwiftUI
import PhotosUI
import OSLog
import QRCode

struct ScannerView: View, Equatable {
    @EnvironmentObject var sceneModel: SceneModel
    @EnvironmentObject var navigationModel: NavigationModel
    @State var viewfinder: Image? = nil
    let camera: Camera = Camera()
    
    @State private var photoToScan: PhotosPickerItem? = nil
    @State private var isPickingPhoto: Bool = false
    @State private var isPickingFile: Bool = false
    @State private var result: Result<String, Camera.QRCodeScanError>? = nil
    
    var body: some View {
        
        ZStack {
            switch result {
            case .none:
                scanner
            case .failure(let error):
                ScannerErrorView(error: error)
                    .toolbar {
                        if Camera.QRCodeScanError.noResult == error {
                            ToolbarItem(placement: .navigation) {
                                ImageButton("Scan Again", systemImage: "chevron.backward", action: {
                                    self.result = nil
                                })
                            }
                        }
                    }
            case .success(let content):
                BuilderView(model: QRModel(title: "Scan Results", design: DesignModel(), content: BuilderModel(text: content)))
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
                            ImageButton("Scan Again", systemImage: "chevron.backward", action: {
                                self.result = nil
                            })
                        }
                    }
            }
        }
        .transition(.slide)
        .animation(.default, value: result)
#if os(iOS)
        .toolbar(.visible, for: .tabBar, .navigationBar)
#endif
    }
    
    static func == (lhs: ScannerView, rhs: ScannerView) -> Bool {
        lhs.camera == rhs.camera
    }
}

// MARK: - Scanner View

extension ScannerView {
    
    var scanner: some View {
        GeometryReader { proxy in
            viewfinder?
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .overlay {
                    Image(systemName: "viewfinder")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .fontWeight(.ultraLight)
                        .frame(maxWidth: min(proxy.size.height, proxy.size.width) * 0.4)
                }
                .clipped()
        }
        .task {
            await camera.start()
            result = camera.scanResult
            
            let imageStream = camera.previewStream.compactMap({ $0.image })
            for await image in imageStream {
                self.viewfinder = image
            }
        }
        .onReceive(camera.scanResult.publisher) { result in
            self.result = result
            Task {
                camera.stop()
            }
        }
        .onDisappear {
            Task {
                camera.stop()
            }
        }
        .background(Color.black, ignoresSafeAreaEdges: .all)
#if os(iOS)
        .persistentSystemOverlays(.hidden)
        .ignoresSafeArea(.all)
        .toolbar(.visible, for: .tabBar, .navigationBar)
        .toolbarBackground(.visible, for: .tabBar, .navigationBar)
        .navigationTitle("Scanner")
        .navigationBarTitleDisplayMode(.inline)
#else
        .navigationTitle("Scanner")
        .ignoresSafeArea(.all)
#endif
        .photosPicker(isPresented: $isPickingPhoto, selection: $photoToScan, matching: .images)
        .onChange(of: photoToScan) { photo in
            if let photo = photo {
                scanFromPhotoPickerItem(photo)
            }
        }
        .fileImporter(isPresented: $isPickingFile, allowedContentTypes: [.image], onCompletion: { result in
            switch result {
            case .success(let success):
                scanFromURL(success)
            case .failure(_):
                Logger.logView.notice("ScannerView: Could not import file.")
            }
        })
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .primaryAction) {
                ImageButton("Switch Cameras", systemImage: "arrow.triangle.2.circlepath", action: {
                    camera.switchCaptureDevice()
                })
                .tint(.primary)
                .disabled(camera.hasMultipleCaptureDevices)
            }
            
            ToolbarItem(placement: .primaryAction) {
                Menu(content: {
                    ImageButton("Scan from Photos", systemImage: "photo") {
                        isPickingPhoto = true
                    }
                    ImageButton("Scan from Files", systemImage: "folder", action: {
                        isPickingFile = true
                    })
                }, label: {
                    Label("Scan Image...", systemImage: "camera.badge.ellipsis")
                }, primaryAction: {
                    isPickingPhoto = true
                })
                .tint(.primary)
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                if camera.isTorchAvailable {
                    ImageButton("Toggle Flash", systemImage: camera.isTorchOn ? "bolt.circle.fill" : "bolt.slash.circle") {
                        camera.toggleTorch()
                    }
                    .tint(.primary)
                }
            }
            
#else
            ToolbarItem(placement: .primaryAction) {
                Menu(content: {
                    ImageButton("Scan from Photos", systemImage: "photo") {
                        isPickingPhoto = true
                    }
                    ImageButton("Scan from Files", systemImage: "folder", action: {
                        isPickingFile = true
                    })
                }, label: {
                    Label("Scan Image...", image: "addPhoto")
                }, primaryAction: {
                    isPickingPhoto = true
                })
            }
#endif
        }
    }
}

// MARK: - Scanner Functions

extension ScannerView {
    
    func scanFromURL(_ url: URL) {
        if url.startAccessingSecurityScopedResource() {
            guard let image = PlatformImage(contentsOfFile: url.absoluteString),
                  let resultsArray = QRCode.DetectQRCodes(in: image),
                  let result = resultsArray.first,
                  let resultString = result.messageString
            else {
                url.stopAccessingSecurityScopedResource()
                camera.stop()
                self.result = .failure(.noResult)
                return
            }
            camera.stop()
            url.stopAccessingSecurityScopedResource()
            self.result = .success(resultString)
        } else {
            sceneModel.toaster = .error(note: "Could not access file")
        }
    }
    
    func scanFromPhotoPickerItem(_ photo: PhotosPickerItem) {
        photo.loadTransferable(type: Data.self, completionHandler: { result in
            switch result {
            case .success(let success):
                guard let data = success,
                      let image = PlatformImage(data: data),
                      let resultsArray = QRCode.DetectQRCodes(in: image),
                      let result = resultsArray.first,
                      let resultString = result.messageString
                else {
                    camera.stop()
                    self.result = .failure(.noResult)
                    return
                }
                camera.stop()
                self.result = .success(resultString)
            case .failure(_):
                Logger.logView.error("ScannerView: Could not access photo from photo picker.")
                sceneModel.toaster = .error(note: "Could not access photo")
            }
        })
    }
}

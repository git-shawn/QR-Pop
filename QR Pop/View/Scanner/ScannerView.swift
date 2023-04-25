//
//  ScannerView.swift
//  QR Pop
//
//  Created by Shawn Davis on 3/17/23.
//

import SwiftUI
import PhotosUI
import QRCode

struct ScannerView: View {
    @EnvironmentObject var sceneModel: SceneModel
    @EnvironmentObject var navigationModel: NavigationModel
    @StateObject private var model = CameraModel()
    
    @State private var viewfinderScale = 1.0
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
#if os(iOS)
                    .toolbarColorScheme(nil, for: .navigationBar, .tabBar)
#endif
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
#if os(iOS)
                    .toolbarColorScheme(.none, for: .navigationBar, .tabBar)
#endif
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
}

// MARK: - Scanner View

extension ScannerView {
    
    var scanner: some View {
        GeometryReader { proxy in
            model.viewfinderImage?
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
            await model.camera.start()
            result = model.camera.scanResult
        }
        .onReceive(model.camera.scanResult.publisher) { result in
            self.result = result
            model.camera.stop()
        }
        .background(Color.black, ignoresSafeAreaEdges: .all)
#if os(iOS)
        .persistentSystemOverlays(.hidden)
        .ignoresSafeArea(.all)
        .toolbarColorScheme(.dark, for: .navigationBar, .tabBar)
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
            case .failure(let failure):
                debugPrint(failure)
                Constants.viewLogger.notice("Failure in Scanner View file importer: \(failure)")
            }
        })
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .primaryAction) {
                ImageButton("Switch Cameras", systemImage: "arrow.triangle.2.circlepath", action: {
                    model.camera.switchCaptureDevice()
                })
                .tint(.white)
                .disabled(!model.camera.hasMultipleCaptureDevices)
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
                .tint(.white)
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                if model.camera.isTorchAvailable {
                    ImageButton("Toggle Flash", systemImage: model.camera.isTorchOn ? "bolt.circle" : "bolt.slash.circle") {
                        model.camera.toggleTorch()
                    }
                    .tint(model.camera.isTorchOn ? .yellow : .white)
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
                model.camera.stop()
                self.result = .failure(.noResult)
                return
            }
            model.camera.stop()
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
                    model.camera.stop()
                    self.result = .failure(.noResult)
                    return
                }
                model.camera.stop()
                self.result = .success(resultString)
            case .failure(let failure):
                debugPrint(failure)
                Constants.viewLogger.error("Could not access photo from photo picker in ScannerView.")
                sceneModel.toaster = .error(note: "Could not access photo")
            }
        })
    }
}

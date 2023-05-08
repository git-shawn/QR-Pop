//
//  CodeScannerView.swift
//  QR Pop
//
//  Created by Shawn Davis on 3/17/23.
//

import SwiftUI
import PhotosUI
import OSLog
import QRCode
import ScanKit

struct CodeScannerView: View {
    @EnvironmentObject var sceneModel: SceneModel
    @EnvironmentObject var navigationModel: NavigationModel
    @Environment(\.verticalSizeClass) var vSizeClass
    @Environment(\.openURL) var openURL
    
    @State private var photoToScan: PhotosPickerItem? = nil
    @State private var isPickingPhoto: Bool = false
    @State private var isPickingFile: Bool = false
    @State private var scanStatus: ScanStatus = .scanning
    @StateObject private var camera = ScanKitCamera()
    
    var body: some View {
        
        ZStack {
            switch scanStatus {
            case .scanning:
                scannerView
            case .notAuthorized:
                notAuthorizedView
            case .failed:
                errorView
            case .result(let payload):
                if !payload.isEmpty {
                    BuilderView(model: QRModel(title: "Scan Results", design: DesignModel(), content: BuilderModel(text: payload)))
                        .transition(.slide)
                        .toolbar {
                            ToolbarItem(placement: .navigation) {
                                ImageButton("Scan Again", systemImage: "chevron.backward", action: {
                                    self.scanStatus = .scanning
                                })
                            }
                        }
                } else {
                    noResultView
                        .transition(.slide)
                        .toolbar {
                            ToolbarItem(placement: .navigation) {
                                ImageButton("Scan Again", systemImage: "chevron.backward", action: {
                                    self.scanStatus = .scanning
                                })
                            }
                        }
                }
                
            }
        }
        .animation(.default, value: scanStatus)
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
                Logger.logView.notice("CodeScannerView: Could not import file.")
            }
        })
    }
}

// MARK: - Scan Status

extension CodeScannerView {
    
    enum ScanStatus: Equatable {
        case scanning
        case result(String)
        case notAuthorized
        case failed
    }
}

// MARK: - Scanning View

extension CodeScannerView {
    
    var scannerView: some View {
        GeometryReader { proxy in
#if os(iOS)
            let controlLayout = ((vSizeClass == .compact) || UIDevice.current.userInterfaceIdiom == .pad) ?
            AnyLayout(VStackLayout(spacing: 20)) : AnyLayout(HStackLayout(spacing: 20))
            let layout = ((vSizeClass == .compact) || UIDevice.current.userInterfaceIdiom == .pad) ?
            AnyLayout(HStackLayout(spacing: 10)) : AnyLayout(VStackLayout(spacing: 10))
#else
            let layout = VStackLayout()
#endif
            let minDimension = min(proxy.size.width, proxy.size.height)
            
                layout {
                    ZStack {
                        ScanKitPreview(camera: camera)
                        
                        Image(systemName: "viewfinder")
                            .resizable()
                            .scaledToFit()
                            .fontWeight(.thin)
                            .foregroundColor(.white)
                            .opacity(0.75)
                            .frame(width: minDimension*0.5, height: minDimension*0.5)
                    }
#if os(iOS)
                        .cornerRadius(min(minDimension*0.08, 20))
#endif
#if os(iOS)
                    controlLayout {
                        Button(action: {
                            camera.toggleTorch()
                        }, label: {
                            if camera.isTorchOn {
                                Label("Toggle Flash Off", systemImage: "bolt.circle.fill")
                                    .foregroundColor(.yellow)
                            } else {
                                Label("Toggle Flash On", systemImage: "bolt.slash.circle")
                                    .foregroundColor(.white)
                            }
                        })
                        .opacity(camera.isTorchAvailable ? 1 : 0.5)
                        .disabled(!camera.isTorchAvailable)
                        
                        Spacer()
                        
                        if camera.hasMultipleCaptureDevices {
                            ImageButton("Switch Camera", systemImage: "arrow.triangle.2.circlepath.camera", action: {
                                camera.cycleCaptureDevices()
                            })
                            .foregroundColor(.white)
                        }
                        
                        Menu(content: {
                            ImageButton("Scan from Photos", systemImage: "photo", action: {
                                isPickingPhoto = true
                            })
                            ImageButton("Scan from Files", systemImage: "folder", action: {
                                isPickingFile = true
                            })
                        }, label: {
                            Label("Scan Image", systemImage: "photo")
                        })
                        .foregroundColor(.white)
                    }
                    .imageScale(.large)
                    .labelStyle(.iconOnly)
                    .padding()
#endif
            }
#if os(iOS)
            .preferredColorScheme((UIDevice.current.userInterfaceIdiom == .pad) ? .dark : .none)
            .toolbarBackground(.black, for: .tabBar)
            .padding(UIDevice.current.userInterfaceIdiom == .pad ? 20 : 0)
            .onDisappear {
                // The view doesn't disappear from the hierarchy when using TabView,
                // so stop isn't automatically called.
                camera.stop()
            }
            .task {
                if !camera.isCapturing {
                    await camera.start()
                }
            }
#endif
        }
        .background(Color.black)
        .task {
            camera.isScanning = true
            camera.symbology = .qr
            do {
                for try await result in camera.resultsStream {
                    self.scanStatus = .result(result)
                }
            } catch let error {
                switch error as! ScanKitError {
                case .notAuthorized:
                    self.scanStatus = .notAuthorized
                case .visionFailed:
                    self.scanStatus = .failed
                }
            }
        }
#if os(macOS)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Menu(content: {
                    camera.getCamerasAsButtons()
                }, label: {
                    Label("Switch Camera", systemImage: "web.camera")
                })
                
                Menu(content: {
                    ImageButton("Scan from Photos", systemImage: "photo") {
                        isPickingPhoto = true
                    }
                    ImageButton("Scan from Files", systemImage: "folder", action: {
                        isPickingFile = true
                    })
                }, label: {
                    Label("Scan Image...", systemImage: "photo")
                }, primaryAction: {
                    isPickingPhoto = true
                })
            }
        }
#else
        .statusBarHidden()
        .navigationTitle("Scanner")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar((UIDevice.current.userInterfaceIdiom == .phone) ? .hidden : .visible, for: .navigationBar)
#endif
    }
}

// MARK: - Scanning Functions

extension CodeScannerView {
    
    func scanFromURL(_ url: URL) {
        if url.startAccessingSecurityScopedResource() {
            guard let data = try? Data(contentsOf: url),
                  let image = PlatformImage(data: data),
                  let resultsArray = QRCode.DetectQRCodes(in: image),
                  let result = resultsArray.first,
                  let resultString = result.messageString
            else {
                url.stopAccessingSecurityScopedResource()
                sceneModel.toaster = .error(note: "Could not scan file")
                return
            }
            url.stopAccessingSecurityScopedResource()
            self.scanStatus = .result(resultString)
        } else {
            sceneModel.toaster = .error(note: "Could not scan file")
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
                    sceneModel.toaster = .error(note: "Could not scan photo")
                    return
                }
                self.scanStatus = .result(resultString)
            case .failure(_):
                Logger.logView.error("CodeScannerView: Could not access photo from photo picker.")
                sceneModel.toaster = .error(note: "Could not scan photo")
            }
        })
    }
}


// MARK: - Invalid Permissions View

extension CodeScannerView {
    
    var notAuthorizedView: some View {
        VStack(spacing: 10) {
#if os(iOS)
            Spacer()
#endif
            Image(systemName: "shield.slash")
                .font(.system(size: 96))
                .foregroundColor(.secondary)
            Text("Invalid Camera Permissions")
                .foregroundColor(.secondary)
#if os(iOS)
            Spacer()
            Button("Modify Permissions", action: {
                openURL(URL(string: UIApplication.openSettingsURLString)!)
            })
            .padding(.bottom)
            .buttonStyle(.bordered)
            .tint(Color.accentColor)
            .buttonBorderShape(.capsule)
#endif
        }
    }
}

// MARK: - Camera Failure View

extension CodeScannerView {
    
    var errorView: some View {
        VStack(spacing: 10) {
            Image(systemName: "eye.trianglebadge.exclamationmark")
                .font(.system(size: 96))
                .foregroundColor(.secondary)
            Text("Camera Not Found")
                .foregroundColor(.secondary)
        }
        .navigationBarBackButtonHidden()
    }
}

// MARK: - No Result View

extension CodeScannerView {
    
    var noResultView: some View {
        VStack(spacing: 10) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 96))
                .foregroundColor(.secondary)
            Text("Could Not Read Code")
                .foregroundColor(.secondary)
        }
    }
}

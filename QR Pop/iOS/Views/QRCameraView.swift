//
//  QRCameraView.swift
//  QR Pop
//
//  Created by Shawn Davis on 12/12/21.
//

import SwiftUI
import CodeScanner
import UniformTypeIdentifiers
import CoreSpotlight
import Intents
import EFQRCode
import AVFoundation

struct QRCameraView: View {
    @StateObject var qrCode = QRCode()
    
    //Unique variables for link
    @State private var scanContent: String = ""
    @State private var hasScanned: Bool = false
    @State private var showPicker: Bool = false
    @State private var noCodeFound: Bool = false
    @State private var flashOn: Bool = false
    @State private var showScannedData: Bool = false
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        withAnimation() {
            hasScanned = true
        }
        switch result {
        case .success(let code):
            qrCode.setContent(string: code.string)
        case .failure(let error):
            print("Scanning failed: \(error)")
        }
    }
    
    func toggleTorch(on: Bool) {
        guard
            let device = AVCaptureDevice.default(for: AVMediaType.video),
            device.hasTorch
        else { return }

        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Flash could not be used")
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                if hasScanned {
                    ScrollView {
                        QRImage()
                            .environmentObject(qrCode)
                            .padding()
                        
                        HStack {
                            Spacer()
                            Button(
                            action: {
                                withAnimation() {
                                    hasScanned = false
                                }
                                scanContent = ""
                                flashOn = false
                                toggleTorch(on: false)
                                qrCode.reset()
                            }) {
                                Label("Scan Another Code", systemImage: "camera")
                            }.buttonStyle(.bordered)
                            Spacer()
                        }
                            
                        QRCodeDesigner()
                            .environmentObject(qrCode)
                            .padding(.horizontal)
                    }
                } else {
                    CodeScannerView(codeTypes: [.qr], scanMode: .once, showViewfinder: false, shouldVibrateOnSuccess: true, completion: self.handleScan)
                        .ignoresSafeArea()
                        .transition(.moveAndFadeToTop)
                    if (AVCaptureDevice.default(for: AVMediaType.video)!.hasTorch) {
                        VStack(alignment: .leading) {
                            HStack {
                                Spacer()
                                Button(
                                action: {
                                    flashOn.toggle()
                                    toggleTorch(on: flashOn)
                                }) {
                                    Label("Toggle Flash", systemImage: flashOn ? "bolt.slash.circle.fill" : "bolt.circle.fill")
                                }
                                .padding()
                                .labelStyle(.iconOnly)
                                .symbolRenderingMode(.hierarchical)
                                .font(.largeTitle)
                                .foregroundColor(.white)
                            }
                            Spacer()
                        }
                    }
                    VStack(alignment: .leading) {
                        if !((UIDevice.current.userInterfaceIdiom == .phone) && geometry.size.width > 700) {
                            Text("Duplicate")
                                .font(.largeTitle)
                                .bold()
                                .padding(.top)
                                .padding(.horizontal)
                        }
                        HStack {
                            Spacer()
                            Button(
                            action: {
                                showPicker = true
                            }) {
                                Label("Duplicate Code from Gallery", systemImage: "photo.on.rectangle.angled")
                            }.buttonStyle(.bordered)
                            .padding()
                            Spacer()
                        }
                    }.background(.regularMaterial)
                    .transition(.moveAndFadeToBottom)
                    .navigationBarHidden(true)
                    .sheet(isPresented: $showPicker) {
                        ImagePicker(sourceType: .photoLibrary, onImagePicked: {image in
                            let result = EFQRCode.recognize(image.cgImage!)
                            if !result.isEmpty {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    qrCode.setContent(string: result.first!)
                                    withAnimation() {
                                        hasScanned = true
                                    }
                                }
                            } else {
                                print("empty!")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    noCodeFound = true
                                }
                            }
                        }).ignoresSafeArea()
                    }
                    VStack(alignment: .center) {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "viewfinder")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: geometry.size.width/2, maxHeight: geometry.size.height/2)
                                .foregroundColor(.white)
                                .opacity(0.7)
                            Spacer()
                        }
                        Spacer()
                        Spacer()
                    }
                }
            }
        }.navigationTitle("Duplicate")
        .alert(isPresented: $noCodeFound, content: {
            Alert(title: Text("No Code Found in Image"))
        })
        .userActivity("shwndvs.QR-Pop.route-selection") { activity in
            activity.isEligibleForSearch = true
            activity.isEligibleForPrediction = true
            activity.isEligibleForHandoff = false
            
            let attributes = CSSearchableItemAttributeSet(contentType: UTType.item)
            attributes.contentDescription = "Copy a QR code using the camera."
            activity.contentAttributeSet = attributes
            activity.title = "Duplicate QR Code"
            
            activity.userInfo = ["route": "duplicate"]
            activity.becomeCurrent()
        }
        .sheet(isPresented: $showScannedData) {
            ModalNavbar(navigationTitle: "Scan Result", showModal: $showScannedData) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Encoded Data")
                                .font(.largeTitle)
                                .bold()
                            Spacer()
                        }
                        Text(verbatim: "\(qrCode.getContent())")
                    }.padding()
                }
            }
        }
        .toolbar(content: {
            HStack{
                Button(
                action: {
                    showScannedData.toggle()
                }) {
                    Label("Show Scanned Data", systemImage: "rectangle.and.text.magnifyingglass")
                }
                ShareButton(shareContent: [qrCode.imgData.image], buttonTitle: "Share")
            }
        })
    }
}

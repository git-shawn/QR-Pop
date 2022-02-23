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
import AVFoundation

struct QRCameraView: View {
    @StateObject var qrCode = QRCode()
    
    //Unique variables for link
    @State private var scanContent: String = ""
    @State private var hasScanned: Bool = false
    @State private var showHelp: Bool = false
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
                    Text("Duplicate")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    HStack {
                        Spacer()
                        Button(
                        action: {
                            showPicker = true
                        }) {
                            Label("Duplicate Code from Gallery", systemImage: "photo.on.rectangle.angled")
                        }.buttonStyle(.bordered)
                        .padding(.bottom)
                        Spacer()
                    }
                }.background(.regularMaterial)
                .transition(.moveAndFadeToBottom)
                .navigationBarHidden(true)
                .sheet(isPresented: $showPicker) {
                    ImagePicker(sourceType: .photoLibrary, onImagePicked: {image in
                        if let features = detectQRCode(image), !features.isEmpty{
                            for case let row as CIQRCodeFeature in features {
                                if (row.messageString != nil) {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        qrCode.setContent(string: row.messageString!)
                                        withAnimation() {
                                            hasScanned = true
                                        }
                                    }
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
        .sheet(isPresented: $showHelp, content: {
            ScannerHelpModal(isPresented: $showHelp)
        })
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
                    showHelp.toggle()
                }) {
                    Label("Help", systemImage: "questionmark.circle")
                }
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

private struct ScannerHelpModal: View {
    @Binding var isPresented: Bool
    var body: some View {
        ModalNavbar(navigationTitle: "Duplicate Help", showModal: $isPresented) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Using Duplicate")
                            .font(.largeTitle)
                            .bold()
                    Group {
                        Text("How does it work?")
                            .font(.headline)
                        Text("QR Pop allows you to recreate a QR code by scanning it. It'll take all of the data inside of that QR code, and place it into a new one! This is a super convenient way to duplicate codes that you didn't save.")
                        Text("Why does QR Pop's code look different from the one I scanned?")
                            .font(.headline)
                        Text("There are a lot of factors that can influence how a QR code looks besides just the information stored within it. While the two codes may not be identical in appearance, they both do the same thing when scanned.")
                        Text("I can't scan my code!")
                            .font(.headline)
                        Text("Make sure the QR code you want to duplicate isn't damaged in any way. Can you scan it with the regular camera app? If the code can't be scanned, it can't be duplicated.")
                    }
                }.padding()
            }
        }
    }
}

/// Detect a QR Code from an Image, then return the result as  CIFeature.
///
/// From https://stackoverflow.com/a/49275021
/// - Parameter image: The image to scan for a QR Code.
/// - Returns: The results of the scan as a CIFeature.
private func detectQRCode(_ image: UIImage?) -> [CIFeature]? {
    if let image = image, let ciImage = CIImage.init(image: image){
        var options: [String: Any]
        let context = CIContext()
        options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
        if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
            options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
        } else {
            options = [CIDetectorImageOrientation: 1]
        }
        let features = qrDetector?.features(in: ciImage, options: options)
        return features

    }
    return nil
}

struct QRCameraView_Previews: PreviewProvider {
    static var previews: some View {
        QRLinkView()
    }
}

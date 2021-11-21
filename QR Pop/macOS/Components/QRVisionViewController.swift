//
//  QRVisionRepresentable.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/26/21.
//
import Cocoa
import Vision
import AVFoundation
import SwiftUI

class QRVisionViewController: NSViewController {
    var captureSession = AVCaptureSession()
    var completionHandler: ((_ payload: String?) -> Void)

    lazy var detectBarcodeRequest = VNDetectBarcodesRequest { request, error in
        guard error == nil else {
            self.showAlert(withTitle: "Barcode error", message: error?.localizedDescription ?? "error")
            return
        }
        self.processClassification(request)
    }
    
    init(completionHandler: @escaping ((_ payload: String?) -> Void)) {
        self.completionHandler = completionHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = NSView()
        self.view.frame = .zero
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermissions()
        setupCameraLiveView()
    }
    
    override func viewWillDisappear() {
        captureSession.stopRunning()
        teardownCapture()
    }
}


extension QRVisionViewController {
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [self] granted in
                if !granted {
                    self.showPermissionsAlert()
                }
            }
        case .denied, .restricted:
            showPermissionsAlert()
        default:
            return
        }
    }

    private func setupCameraLiveView() {
        captureSession.sessionPreset = .medium

        guard
            let device = AVCaptureDevice.default(for: .video),
            let videoDeviceInput = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(videoDeviceInput) else {
                showAlert(
                withTitle: "Cannot Find Camera",
                message: "QR Pop was unable to locate the default camera.")
                return
            }

        captureSession.addInput(videoDeviceInput)

        let captureOutput = AVCaptureVideoDataOutput()
        captureOutput.alwaysDiscardsLateVideoFrames = true

        let videoDataOutputQueue = DispatchQueue(label: "shwndvs.QR-Pop.VisionQRScanning")
        captureOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        captureSession.addOutput(captureOutput)

        configurePreviewLayer()

        captureSession.startRunning()
    }

    func processClassification(_ request: VNRequest) {
        guard let barcodes = request.results else { return }
        DispatchQueue.main.async { [self] in
            if captureSession.isRunning {
                view.layer?.sublayers?.removeSubrange(1...)

                for barcode in barcodes {
                    guard
                    let potentialQRCode = barcode as? VNBarcodeObservation,
                    potentialQRCode.symbology == .qr,
                    potentialQRCode.confidence > 0.9
                    else { return }

                    observationHandler(payload: potentialQRCode.payloadStringValue)
                }
            }
        }
    }

    func observationHandler(payload: String?) {
        completionHandler(payload)
        captureSession.stopRunning()
    }
}

extension QRVisionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let imageRequestHandler = VNImageRequestHandler(
        cvPixelBuffer: pixelBuffer,
        orientation: .right)

        do {
            try imageRequestHandler.perform([detectBarcodeRequest])
        } catch {
            print(error)
        }
    }
}

extension QRVisionViewController {
    private func configurePreviewLayer() {
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer.frame = view.frame
        cameraPreviewLayer.contentsGravity = .resizeAspectFill
        cameraPreviewLayer.videoGravity = .resizeAspectFill
        cameraPreviewLayer.connection?.automaticallyAdjustsVideoMirroring = true
        self.view.layer = cameraPreviewLayer
    }

    private func showAlert(withTitle title: String, message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert.init()
            alert.messageText = title
            alert.informativeText = message
            alert.runModal()
        }
    }

    private func showPermissionsAlert() {
        showAlert(
        withTitle: "Camera Permissions",
        message: "Please open Settings and grant permission for this app to use your camera.")
    }
    
    private func teardownCapture() {
        view.removeFromSuperview()
        view.layer = nil
    }
}

struct QRVisionViewControllerRepresentable: NSViewControllerRepresentable {
    var completionHandler: ((_ payload: String?) -> Void)
    
    func makeNSViewController(context: Context) -> some NSViewController {
        let controller = QRVisionViewController(completionHandler: {payload in
            completionHandler(payload)
        })
        return controller
    }
    
    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
        //nothing
    }
}

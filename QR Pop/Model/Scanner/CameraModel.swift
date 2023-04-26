//
//  CameraModel.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/25/23.
//

import AVFoundation
import Combine
import SwiftUI

class CameraModel: ObservableObject {
    let camera = Camera()
    
    @Published var viewfinderImage: Image?
    @Published var codeScanResult: (Result<String, Camera.QRCodeScanError>)?
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        Task {
            await handleViewfinderStream()
        }
    }
    
    func handleViewfinderStream() async {
        let imageStream = camera.previewStream
            .map { $0.image }
        
        for await image in imageStream {
            Task { @MainActor in
                viewfinderImage = image
            }
        }
    }
}

fileprivate extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent)
        else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

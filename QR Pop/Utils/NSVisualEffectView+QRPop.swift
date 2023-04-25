//
//  NSVisualEffectView+QRPop.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/12/23.
//

#if os(macOS)
import SwiftUI

struct VisualEffectView: NSViewRepresentable {
    
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = NSVisualEffectView.State.active
        return visualEffectView
    }
    
    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}

extension View {
    
    func windowMaterial(
        material: NSVisualEffectView.Material = .sidebar,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow) -> some View {

            background(VisualEffectView(material: material, blendingMode: blendingMode).ignoresSafeArea())
        }
}

#endif

//
//  MenuBarView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/22/23.
//
#if os(macOS)

import SwiftUI
import OSLog

struct MenuBarView: View {
    var model = MenuBarModel()
    @AppStorage("isMenuBarActive", store: .appGroup) var isMenuBarActive: Bool = true
    @Environment(\.dismiss) var dismiss
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        if model.hasCaptureAccess {
            VStack(alignment: .leading, spacing: 15) {
                Button(action: {
                    do {
                        let results = try model.captureAndScanRegion()
                        openWindow(id: "menuBarResults", value: results)
                        dismiss()
                    } catch let error {
                        Logger.logView.error("MenuBarView: Could not capture region of display.")
                        let alert = NSAlert(error: error)
                        alert.alertStyle = .critical
                        alert.runModal()
                        dismiss()
                    }
                }, label: {
                    Label("Scan Region", systemImage: "rectangle.dashed.badge.record")
                })
                .buttonStyle(MenuBarButtonStyle())
                
                Button(action: {
                    do {
                        let results = try model.captureAndScanMainDisplay()
                        openWindow(id: "menuBarResults", value: results)
                        dismiss()
                    } catch let error {
                        Logger.logView.error("MenuBarView: Could not capture entire display.")
                        let alert = NSAlert(error: error)
                        alert.alertStyle = .critical
                        alert.runModal()
                        dismiss()
                    }
                }, label: {
                    Label("Scan Entire Display", systemImage: "menubar.dock.rectangle.badge.record")
                })
                .buttonStyle(MenuBarButtonStyle())
            }
            .padding(EdgeInsets(top: 15, leading: 10, bottom: 15, trailing: 10))
            .frame(maxWidth: 200)
            .background(
            Image(systemName: "qrcode")
                .resizable()
                .scaledToFill()
                .scaleEffect(1.2)
                .rotationEffect(Angle(degrees: 45))
                .bold()
                .opacity(0.15)
                .blendMode(.softLight)
            )
        } else {
            VStack(spacing: 10) {
                Image(systemName: "lock.shield.fill")
                    .symbolRenderingMode(.hierarchical)
                    .font(.system(size: 56))
                Text("You must allow \n**Screen Recording**\n access for QR Pop in Settings to use the Menu Bar Scanner.")
                    .multilineTextAlignment(.center)
                Button("Disable Menu Bar App", role: .destructive, action: {
                    isMenuBarActive = false
                    dismiss()
                })
                .padding(.vertical, 10)
            }
            .padding(10)
            .frame(maxWidth: 200)
        }
    }
}

private struct MenuBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.regularMaterial)
                    .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(.quaternary)
            )
            .contrast(configuration.isPressed ? 0.75 : 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

struct MenuBarView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarView()
    }
}

#endif

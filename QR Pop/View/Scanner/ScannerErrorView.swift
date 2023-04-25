//
//  ScannerErrorView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/17/23.
//

import SwiftUI

struct ScannerErrorView: View {
    let error: Camera.QRCodeScanError
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Group {
            switch error {
            case .notAuthorized:
                invalidPermissions
            case .initFailure:
                cameraFailure
            case .noResult:
                noResult
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#else
        .ignoresSafeArea()
#endif
        .navigationTitle("Scan Results")
    }
}

// MARK: - Invalid Permissions View

extension ScannerErrorView {
    
    var invalidPermissions: some View {
        VStack(spacing: 10) {
#if os(iOS)
            Spacer()
#endif
            Image(systemName: "shield.slash")
                .font(.system(size: 72))
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

extension ScannerErrorView {
    
    var cameraFailure: some View {
        VStack(spacing: 10) {
            Image(systemName: "eye.trianglebadge.exclamationmark")
                .font(.system(size: 72))
                .foregroundColor(.secondary)
            Text("Camera Not Found")
                .foregroundColor(.secondary)
        }
        .navigationBarBackButtonHidden()
    }
}

// MARK: - No Result View

extension ScannerErrorView {
    
    var noResult: some View {
        VStack(spacing: 10) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 72))
                .foregroundColor(.secondary)
            Text("Could Not Read Code")
                .foregroundColor(.secondary)
        }
    }
}

struct ScannerErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerErrorView(error: .notAuthorized)
            .previewDisplayName("Invalid Permissions")
        ScannerErrorView(error: .initFailure)
            .previewDisplayName("Camera Failure")
        ScannerErrorView(error: .noResult)
            .previewDisplayName("No Result")
    }
}

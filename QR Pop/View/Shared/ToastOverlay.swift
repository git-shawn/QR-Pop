//
//  ToastOverlay.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/11/23.
//

import SwiftUI

struct ToastOverlayModifier: ViewModifier {
    
    @Binding var toast: SceneModel.Toast?
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
                .zIndex(0)
            if (toast != nil) {
                ToastOverlay(toast: toast)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 3)
                    .zIndex(1)
                    .transition(.move(edge: .top))
            }
        }
        .animation(.easeIn, value: toast)
        .onChange(of: toast, perform: { toast in
            if (toast != nil) {
                
#if canImport(UIKit)
                switch toast {
                case .error(note: _):
                    Haptics.shared.notify(.error)
                case .success(note: _), .saved(note: _), .copied(note: _):
                    Haptics.shared.notify(.success)
                case .custom(image: _, imageColor: _, title: _, note: _):
                    Haptics.shared.notify(.warning)
                case .none:
                    break
                }
#endif
                
                Task { @MainActor in
                    try await Task.sleep(for: .seconds(2))
                    self.toast = nil
                }
            }
        })
    }
}

// MARK: - Toast View

struct ToastOverlay: View {
    init(toast: SceneModel.Toast?) {
        switch toast {
        case .error(note: let note):
            self.image = Image(systemName: "exclamationmark.octagon")
            self.imageColor = .red
            self.title = "Error"
            self.note = note
        case .success(note: let note):
            self.image = Image(systemName: "checkmark")
            self.imageColor = .accentColor
            self.title = "Success"
            self.note = note
        case .copied(note: let note):
            self.image = Image(systemName: "list.clipboard")
            self.imageColor = nil
            self.title = "Copied"
            self.note = note
        case .saved(note: let note):
            self.image = Image(systemName: "square.and.arrow.down")
            self.imageColor = nil
            self.title = "Saved"
            self.note = note
        case .custom(image: let image, imageColor: let color, title: let title, note: let note):
            self.image = image
            self.imageColor = color
            self.title = title
            self.note = note
        case .none:
            break
        }
    }
    
    /// A symbol to show alongside the toast.
    /// - Warning: Only use default or custom SF Symbols. Other images may not fit as expected.
    var image: Image?
    /// The image's color. Gray if `nil`.
    var imageColor: Color?
    /// The toast's title. This may only appear is one line so be terse.
    var title: String?
    /// A small note further explaining the toast.
    var note: String?
    
    var body: some View {
        HStack(spacing: 16) {
            image
                .foregroundStyle((imageColor != nil) ? imageColor! : .secondary)
                .font(.title2)
            VStack(alignment: .leading, spacing: 3) {
                Text(title ?? "")
                    .fontWeight(.medium)
                    .lineLimit(1)
                if (note != nil) {
                    Text(note!)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fontWeight(.medium)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 25)
        .background(.ultraThickMaterial)
        .clipShape(Capsule(style: .continuous))
#if os(macOS)
        .overlay(
            Capsule(style: .continuous)
                .stroke(LinearGradient.macAccentStyle, lineWidth: 1)
                .opacity(0.2)
        )
#endif
        .padding()
    }
}

// MARK: - View Extension

extension View {
    
    /// Presents a toast overlaying the modified View.
    /// - Parameter toast: The ``SceneModel.Toast`` to overlay.
    func toast(_ toast: Binding<SceneModel.Toast?>) -> some View {
        modifier(ToastOverlayModifier(toast: toast))
    }
}

#if DEBUG
struct ToastOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            ForEach(0..<3) { _ in
                Text(Constants.loremIpsum)
                    .padding()
            }
        }
        .toast(.constant(.success(note: "Successful Toast!")))
    }
}
#endif

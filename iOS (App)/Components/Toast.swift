//
//  Toast.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/17/21.
//

import Foundation
import SwiftUI

/// Display a "Toast" message overlaying a View.
struct Toast<Presenting>: View where Presenting: View {

    /// If the Toast is showing or not.
    @Binding var isShowing: Bool
    
    /// The view that will present the toast.
    let presenting: () -> Presenting
    
    /// The text to show within the toast
    let text: String
    
    /// The icon to show in the toast
    let icon: String

    var body: some View {

        GeometryReader { geometry in

            ZStack(alignment: .center) {

                self.presenting()
                    .zIndex(1)
                    .blur(radius: 20)

                VStack {
                    Label(text, systemImage: icon)
                        .font(.headline)
                }
                .frame(width: 150,
                       height: 30)
                .padding(.vertical)
                .background(.ultraThickMaterial)
                .foregroundColor(.secondary)
                .cornerRadius(40)
                .transition(.slide)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                      withAnimation {
                        self.isShowing = false
                      }
                    }
                }
                .opacity(self.isShowing ? 1 : 0)
                .zIndex(2)
            }

        }

    }

}

extension View {
    
    /// Overlay a toast onto a view
    /// - Parameters:
    ///   - isShowing: If the toast should be visible or not
    ///   - text: The text content of the toast
    /// - Returns: A toast overlay view
    func toast(isShowing: Binding<Bool>, text: String, icon: String) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              text: text, icon: icon)
    }
}

//
//  View+GeometryProxy.swift
//  QR Pop
//
//  Credit Federico Zanetello via Five Stars
//  Source: https://fivestars.blog/articles/swiftui-share-layout-information/
//  Modified by Shawn Davis on 4/12/2023
//

import SwiftUI

extension View {
    
    /// Read the size of a view.
    /// - Returns: The view's size.
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    
    /// Read the frame of a view.
    /// - Returns: The view's frame as a `CGRect`.
    func readFrame(in coordinateSpace: CoordinateSpace = .local, onChange: @escaping (CGRect) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: FramePreferenceKay.self, value: geometryProxy.frame(in: coordinateSpace))
            }
        )
        .onPreferenceChange(FramePreferenceKay.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

private struct FramePreferenceKay: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

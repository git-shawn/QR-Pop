//
//  CarouselView.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/12/23.
//

import SwiftUI

struct CarouselView<Content: View>: View {
    @ViewBuilder var content: Content
    @State private var masking: Bool = false
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                content
            }
            .padding(.trailing, 60)
            .readFrame(in: .named("templateCarouselSpace")) { frame in
                withAnimation(.easeInOut) {
                    masking = frame.origin.x < 0.0
                }
            }
        }
        .coordinateSpace(name: "templateCarouselSpace")
        .mask {
            Rectangle()
                .overlay(alignment: .leading) {
                    ScrollMask(isLeading: true)
                        .opacity(masking ? 1 : 0)
                }
                .overlay(alignment: .trailing) {
                    ScrollMask(isLeading: false)
                }
        }
    }
}

/// Creates a gradient in the horizontal direction, intended to be used as a mask.
private struct ScrollMask: View {
    let isLeading: Bool
    
    var body: some View {
        LinearGradient(colors: [.black, .clear], startPoint: isLeading ? .leading : .trailing, endPoint: isLeading ? .trailing : .leading)
            .frame(width: 60)
            .blendMode(.destinationOut)
    }
}

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselView {
            ForEach(0..<10) { i in
                Rectangle()
                    .fill(Color.random)
                    .frame(width: 52, height: 52)
                    .overlay(
                        Text("\(i)")
                            .bold()
                    )
            }
        }
        .padding()
        .background(.tertiary)
    }
}

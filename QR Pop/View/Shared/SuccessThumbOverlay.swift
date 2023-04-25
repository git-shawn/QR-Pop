//
//  SuccessThumbOverlay.swift
//  QR Pop
//
//  Created by Shawn Davis on 4/21/23.
//

import SwiftUI

struct SuccessThumb: View {
    var size: CGFloat = 150
    var color: Color = .accentColor
    var rainbowBurst: Bool = false
    
    @Binding var isAnimating: Bool
    
    @State private var animating: Bool = false
    @State private var erupting: Bool = false
    
    private let colors: [Color] = [.pink, .yellow, .orange, .indigo, .green, .mint, .purple]
    
    var body: some View {
        ZStack {
            ForEach(0..<75) { _ in
                Capsule()
                    .rotation(Angle(degrees: Double.random(in: 0..<360)))
                    .frame(width: 20, height: 10)
                    .scaleEffect(erupting ? 1 : 0)
                    .foregroundColor(rainbowBurst ? colors.randomElement() : color)
                    .brightness(rainbowBurst ? 0 : Double.random(in: 0...0.75))
                    .offset(x: erupting ? (Double.random(in: -1...1) * 500) : 0, y: erupting ? (Double.random(in: -1...1) * 500) : 0)
                    .opacity(erupting ? 0 : 1)
                    .padding()
            }
            Image(systemName: "hand.thumbsup.fill")
                .resizable()
                .scaledToFit()
                .scaleEffect(animating ? 1 : 0)
                .foregroundColor(color)
                .rotationEffect(animating ? Angle(degrees: 0) : Angle(degrees: 90))
                .padding(size*0.05)
        }
        .frame(width: size, height: size)
        .onChange(of: isAnimating) { isAnimating in
            withAnimation(.interactiveSpring(
                response: 0.3,
                dampingFraction: 0.25,
                blendDuration: 0.4
            )) {
                animating = isAnimating
            }
            withAnimation(.easeInOut.speed(0.25)) {
                erupting = isAnimating
            }
        }
    }
}

struct SuccessThumbOverlay: ViewModifier {
    var size: CGFloat
    var color: Color
    var rainbowBurst: Bool
    @Binding var isAnimating: Bool
    
    init(size: CGFloat = 150, color: Color = .accentColor, rainbowBurst: Bool = false, isAnimating: Binding<Bool>) {
        self.size = size
        self.color = color
        self.rainbowBurst = rainbowBurst
        self._isAnimating = isAnimating
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .zIndex(1)
            SuccessThumb(size: size, color: color, rainbowBurst: rainbowBurst, isAnimating: $isAnimating)
                .zIndex(0)
        }
    }
}

struct SuccessThumb_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
#if os(macOS)
            .frame(width: 500, height: 500)
#endif
    }
    
    private struct PreviewWrapper: View {
        @State private var isSuccess = false
        
        var body: some View {
            VStack {
                Button("Show Success", action: {
                    isSuccess.toggle()
                })
                .buttonStyle(.borderedProminent)
            }
            .modifier(SuccessThumbOverlay(isAnimating: $isSuccess))
        }
    }
}

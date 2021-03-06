//
//  ImageSlider.swift
//  QR Pop (macOS)
//
//  Created by Shawn Davis on 11/2/21.
//

import SwiftUI

struct ImageSlider: View {
    var images: Array<String>
    @State private var index: Int = 0
    @State private var btnOpacity: Double = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            HStack() {
                Group {
                    Button(action: {
                        if(index > 0) {
                            DispatchQueue.main.async {
                                withAnimation(.easeInOut) {
                                    index -= 1
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                withAnimation(.easeInOut) {
                                    index = (images.count - 1)
                                }
                            }
                        }
                    }){
                        Image(systemName: "chevron.backward")
                            .font(.headline)
                            .foregroundColor(Color(NSColor.labelColor))
                            .padding(8)
                            .background(.regularMaterial)
                            .clipShape(Circle()
                            )
                    }
                    Spacer()
                    Button(action: {
                        if(index < (images.count - 1)) {
                            DispatchQueue.main.async {
                                withAnimation(.easeInOut) {
                                    index += 1
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                withAnimation(.easeInOut) {
                                    index = 0
                                }
                            }
                        }
                    }){
                        Image(systemName: "chevron.forward")
                            .font(.headline)
                            .foregroundColor(Color(NSColor.labelColor))
                            .padding(8)
                            .background(.regularMaterial)
                            .clipShape(Circle()
                            )
                    }
                }.buttonStyle(PlainButtonStyle())
                .padding(5)
            }
            .opacity(btnOpacity)
            .zIndex(2)
            .frame(width: 300, height: 300)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(self.images, id: \.self) { image in
                        Image(image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .brightness(colorScheme == .dark ? 0.02 : -0.02)
                    }
                }
            }.content.offset(x: 300 * -CGFloat(self.index))
            .frame(width: 300, height: 300, alignment: .leading)
            .cornerRadius(16)
            .zIndex(1)
            VStack {
                PageIndicator(index: $index, maxIndex: (images.count - 1))
            }.frame(width: 300, height: 300, alignment: .bottomTrailing)
            .zIndex(3)
        }.onHover(perform: { hovering in
            if hovering {
                btnOpacity = 0.9
            } else {
                btnOpacity = 0
                NSCursor.arrow.set()
            }
        })
    }
}

struct PageIndicator: View {
    @Binding var index: Int
    let maxIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0...maxIndex, id: \.self) { index in
                Circle()
                    .fill(index == self.index ? Color.primary : Color.gray)
                    .frame(width: 8, height: 8)
            }.opacity(0.8)
        }
        .padding(15)
    }
}

struct ImageSlider_Previews: PreviewProvider {
    static var images = ["macsafext1", "macsafext2", "macsafext3", "macsafext4"]
    static var previews: some View {
        ImageSlider(images: images)
    }
}

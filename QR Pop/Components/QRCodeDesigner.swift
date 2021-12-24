//
//  QRCodeDesigner.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 10/18/21.
//
import SwiftUI

/// A panel of design elements to customize a QR code
struct QRCodeDesigner: View {
    @EnvironmentObject var qrCode: QRCode
    
    @State var showOverlayPicker: Bool = false
    @State private var warningVisible: Bool = false
    @State private var showPicker: Bool = false
    #if os(iOS)
    @State private var showDesigner: Bool = false
    #else
    @State private var showDesigner: Bool = true
    #endif
    
    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text("Code Design")
                    .font(.headline)
                    .padding(.vertical, 10)
                    .padding(.leading)
                #if os(iOS)
                Image(systemName: "chevron.right.circle")
                    .foregroundColor(.accentColor)
                    .imageScale(.large)
                    .transition(.move(edge: .leading))
                    .rotationEffect(.degrees(showDesigner ? 90 : 0))
                    .animation(.spring(), value: showDesigner)
                    .onTapGesture {
                        withAnimation() {
                            showDesigner.toggle()
                        }
                    }
                #endif
                Spacer()
                if (!showDesigner && warningVisible) {
                    Image(systemName: "eye.trianglebadge.exclamationmark")
                        .foregroundColor(.yellow)
                        .imageScale(.large)
                        .padding(.trailing)
                }
            }
            if (showDesigner) {
                VStack {
                    if warningVisible {
                        HStack(alignment: .center, spacing: 15) {
                            Image(systemName: "eye.trianglebadge.exclamationmark")
                                .font(.largeTitle)
                            VStack(alignment: .leading) {
                                Text("The background and foreground colors are too similar.")
                                    .font(.headline)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("This code may not scan. Consider picking colors with more contrast.")
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }.foregroundColor(Color("WarningLabel"))
                        .frame(maxWidth: 350)
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color("WarningBkg"))
                                .padding(5)
                        )
                        .animation(.spring(), value: warningVisible)
                        .padding(.top, 5)
                        .padding(.bottom, 15)
                    }
                    VStack(alignment: .center, spacing: 10) {
                        ColorPicker("Background color", selection: $qrCode.backgroundColor, supportsOpacity: true)
                        ColorPicker("Foreground color", selection: $qrCode.foregroundColor, supportsOpacity: false)
                        
                        HStack(alignment: .firstTextBaseline) {
                            #if os(iOS)
                            Text("Shape Style")
                            Spacer()
                            #endif
                        Picker("Shape Style", selection: $qrCode.pointStyle, content: {
                            Label("Square", systemImage: "square").tag(QRPointStyle.square)
                            Label("Circle", systemImage: "circle").tag(QRPointStyle.circle)
                            Label("Diamond", systemImage: "diamond").tag(QRPointStyle.diamond)
                            Label("Star", systemImage: "star").tag(QRPointStyle.star)
                        })
                        #if os(iOS)
                        .pickerStyle(.menu)
                        .padding(.vertical, 6)
                        .padding(.horizontal)
                        .background(Color("ButtonBkg"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        #endif
                        .padding(.top)
                        .onChange(of: qrCode.pointStyle, perform: {_ in qrCode.generate()})
                        }
                        
                        #if os(iOS)
                        Button(action: {
                            showPicker = true
                        }) {
                            Label("Add Image", systemImage: "photo")
                            .labelStyle(.titleOnly)
                            .padding(5)
                            .frame(maxWidth: 350)
                        }.popover(isPresented: $showPicker) {
                            ImagePicker(sourceType: .photoLibrary, onImagePicked: {image in
                                qrCode.overlayImage = image.pngData()!
                            }).ignoresSafeArea()
                        }
                        #if os(iOS)
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.accentColor)
                        .padding(.vertical, 6)
                        .padding(.horizontal)
                        .background(Color("ButtonBkg"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        #else
                        .buttonStyle(QRPopPlainButton())
                        #endif
                        .padding(.vertical, 10)
                        #endif
                        
                    }.padding(.horizontal, 20)
                    .onChange(of: [qrCode.backgroundColor, qrCode.foregroundColor], perform: {_ in
                        qrCode.generate()
                        evaluateContrast()
                    }).padding(.bottom)
                }.transition(.moveAndFade)
            }
        }.padding(5)
        #if os(iOS)
        .background(.thickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.vertical)
        #else
        .onAppear(perform: {
            evaluateContrast()
        })
        #endif
    }
    
    private func evaluateContrast() {
        let cRatio = qrCode.backgroundColor.contrastRatio(with: qrCode.foregroundColor)
        if cRatio < 2.5 {
            withAnimation {
                warningVisible = true
            }
        } else {
            withAnimation {
                warningVisible = false
            }
        }
    }
}

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        )
    }
}

//
//  MakeQRView.swift
//  QR Pop (iOS)
//
//  Created by Shawn Davis on 9/26/21.
//

import SwiftUI
import UniformTypeIdentifiers

// Create a slide-in/slide-out transition for the toast
extension AnyTransition {
    static var moveAndFade: AnyTransition {
        let insertion = AnyTransition.move(edge: .top)
            .combined(with: .opacity)
        let removal = AnyTransition.move(edge: .top)
            .combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }
}

struct MakeQRView: View {
    @State private var text = "" //QR Code value
    @State private var bgColor = Color.white //QR code background color
    @State private var fgColor = Color.black //QR code foreground color
    @State private var showToast = false //Boolean representing toast visibility
    let qrCode = QRCode()
    let imageSaver = ImageSaver()
        
    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                //If true, displays a toast to indicate the save was successful
                if showToast {
                Label("Saved", systemImage: "checkmark")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(16)
                    .background(
                        Capsule()
                        .foregroundColor(Color(UIColor.systemBackground))
                        .shadow(color: Color(.black).opacity(0.16), radius: 12, x: 0, y: 5)
                    )
                    .transition(.moveAndFade)
                    .onAppear {
                      DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                          showToast = false
                        }
                      }
                    }
                    .zIndex(2)
                }
                
                VStack() {
                    // Display the QR code
                    Image(uiImage: UIImage(data: qrCode.generate(content: text, bg: bgColor, fg: fgColor)!)!)
                        .interpolation(.none)
                        .resizable()
                        .frame(width: 330, height: 330)
                        .accessibilityLabel("QR Code Image")
                        .onDrag({
                            let qrImage = qrCode.generate(content: text, bg: bgColor, fg: fgColor)!
                            return NSItemProvider(item: qrImage as NSSecureCoding, typeIdentifier: UTType.png.identifier)
                        })
                        .contextMenu {
                            Button {
                                let imageSaver = ImageSaver()

                                imageSaver.successHandler = {
                                    withAnimation {
                                        showToast = true
                                    }
                                }

                                imageSaver.writeToPhotoAlbum(image: UIImage(data: qrCode.generate(content: text, bg: bgColor, fg: fgColor)!)!)
                            } label: {
                                Label("Save code", systemImage: "square.and.arrow.down")
                            }
                        }
                    
                    //Accept URL to generate QR code from
                    TextField("Enter URL", text: $text)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.tertiarySystemFill)))
                        .foregroundColor(.primary)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .submitLabel(.done)
                        .disableAutocorrection(true)
                        .padding()
                    
                    //Allow the user to pick a foreground and background color for the qr code
                    VStack() {
                        ColorPicker("Background color", selection: $bgColor, supportsOpacity: false)
                        ColorPicker("Foreground color", selection: $fgColor, supportsOpacity: false)
                    }.padding(.horizontal, 20)
                }.padding(.top, 20)
                .zIndex(1)
            }
        }.navigationBarTitle(Text("QR Generator"), displayMode: .large)
        .navigationBarItems(trailing:
            HStack{
            Button(
                action: {
                    let imageSaver = ImageSaver()

                    imageSaver.successHandler = {
                        withAnimation {
                            showToast = true
                        }
                    }

                    imageSaver.writeToPhotoAlbum(image: UIImage(data: qrCode.generate(content: text, bg: bgColor, fg: fgColor)!)!)
                }){
                    Image(systemName: "square.and.arrow.down")
                }
            })
    }
}

struct MakeQRView_Previews: PreviewProvider {
    static var previews: some View {
        MakeQRView()
.previewInterfaceOrientation(.portrait)
    }
}
